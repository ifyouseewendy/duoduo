require 'thor'
require 'roo'
require 'roo-xls'
require 'axlsx'

class Import < Thor

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  desc "import staff_and_contract", "导入信息到员工档案和劳务合同"
  option :from, required: true # 文件名为子公司名称
  option :sub_company_name     # 如果 from 文件名称不是子公司名称时，需要提供此参数
  def staff_and_contract
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])
    file = Pathname(options[:from])

    load_rails

    sub_company_name = options[:sub_company_name]\
                        || file.basename.to_s.split('.')[0]
    sub_company_id = SubCompany.where(name: sub_company_name).first.try(:id)
    raise "未找到子公司(名称: #{sub_company_name})。请保证 from 文件名为子公司名，或提供 sub_company_name 参数" \
      if sub_company_id.nil?

    xlsx = Roo::Spreadsheet.open(file.to_s)

    failed = [ [], [], [], [] ]

    sheet_id = 0
    sheet = xlsx.sheet(sheet_id)
    puts "--> Start processing Sheet #{sheet_id}"

    # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 年龄, 性别, 民族, 学历, 家庭住址, 联系电话, 社保参加工作时间, 本单位社保参保时间, 本单位医保参保时间, 到本单位时间, 四平东方合同起止时间, 通讯合同起止时间, 社保个人编号, 医保个人编号, 医保卡号, 备案时间, 备案地, 工作地点, 工种, 备注, 公主岭合同起止时间, 公主岭社保个人编号, 公主岭医保个人编号

    last_row = sheet.last_row
    (2..last_row).each do |row_id|
      puts "... Processing #{row_id}/#{last_row}" if row_id % 50 == 0

      nest_index, name, corporation_id, corporation_name, identity_card, age, gender, nation, grade, address, telephone, social_insurance_start_date, current_social_insurance_start_date, current_medical_insurance_start_date, arrive_current_company_at, dongfang_siping_contract_dates, current_contract_dates, social_insurance_serial, medical_insurance_serial, medical_insurance_card, backup_date, backup_place, work_place, work_type, remark, dongfang_gongzhuling_contract_dates, dongfang_gongzhuling_social_insurance_serial, dongfang_gongzhuling_medical_insurance_serial = \
        sheet.row(row_id).map{|col| String === col ? col.strip : col}

      in_service = true
      contract_type = :normal_contract

      begin
        normal_corporation_id = NormalCorporation.find_or_create_by!(name: corporation_name).id
        raise "未找到合作单位(名称: #{corporation_name})" if normal_corporation_id.nil?

        # Need to confirm
        #
        #   :account
        #   :account_bank
        #   :birth
        ns = NormalStaff.create!(
          nest_index: nest_index.to_i,
          name: name,
          account: nil,
          account_bank: nil,
          identity_card: identity_card.to_s,
          birth: nil,
          age: age,
          gender: {'男' => 'male', '女' => 'female'}[gender],
          nation: nation,
          grade: grade,
          address: address,
          telephone: telephone.to_s,
          social_insurance_start_date: parse_date(social_insurance_start_date),
          in_service: in_service,
          remark: remark,
          normal_corporation_id: normal_corporation_id,
          sub_company_id: sub_company_id
        )

        # Need to confirm
        #
        #   :has_accident_insurance
        #   :social_insurance_base
        #   :medical_insurance_base
        #   :house_accumulation_base
        #   :release_date
        #   :social_insurance_release_date
        #   :medical_insurance_release_date
        contract_attrs = {
          contract_type: contract_type,
          in_contract: true,
          contract_start_date: parse_date(current_contract_dates.split('-')[0]),
          contract_end_date: parse_date(current_contract_dates.split('-')[1]),
          arrive_current_company_at: parse_date(arrive_current_company_at),
          has_social_insurance: true,
          has_medical_insurance: true,
          has_accident_insurance: nil,
          current_social_insurance_start_date: parse_date(current_social_insurance_start_date),
          current_medical_insurance_start_date: parse_date(current_medical_insurance_start_date),
          social_insurance_base: nil.to_i,
          medical_insurance_base: nil.to_i,
          house_accumulation_base: nil.to_i,
          social_insurance_serial: social_insurance_serial.to_s,
          medical_insurance_serial: medical_insurance_serial.to_s,
          medical_insurance_card: medical_insurance_card.to_s,
          backup_date: parse_date(backup_date),
          backup_place: backup_place,
          work_place: work_place,
          work_type: work_type,
          release_date: nil,
          social_insurance_release_date: nil,
          medical_insurance_release_date: nil,
          remark: nil,
          sub_company_id: sub_company_id,
          normal_corporation_id: normal_corporation_id,
          normal_staff_id: ns.id,
        }

        # Create current contract
        LaborContract.create!(contract_attrs)

        # Create dongfang siping contract
        if dongfang_siping_contract_dates.present?
          contract_attrs_siping = contract_attrs.merge({
            in_contract: false,
            contract_start_date: parse_date(dongfang_siping_contract_dates.split('-')[0]),
            contract_end_date: parse_date(dongfang_siping_contract_dates.split('-')[1]),
          })
          LaborContract.create!(contract_attrs_siping)
        end

        # Create dongfang gongzhuling contract
        if dongfang_gongzhuling_contract_dates.present?
          contract_attrs_gongzhuling = contract_attrs.merge({
            in_contract: false,
            contract_start_date: parse_date(dongfang_gongzhuling_contract_dates.split('-')[0]),
            contract_end_date: parse_date(dongfang_gongzhuling_contract_dates.split('-')[1]),
            social_insurance_serial: dongfang_gongzhuling_social_insurance_serial,
            medical_insurance_serial: dongfang_gongzhuling_medical_insurance_serial
          })
          LaborContract.create!(contract_attrs_gongzhuling)
        end
      rescue => e
        failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
      end
    end

    sheet_id = 1
    sheet = xlsx.sheet(sheet_id)
    puts "--> Start processing Sheet #{sheet_id}"


    # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 年龄, 性别, 民族, 学历, 家庭住址, 联系电话, 社保参加工作时间, 本单位社保参保时间, 本单位医保参保时间, 到本单位时间, 四平东方合同起止时间, 通讯合同起止时间 , 社保个人编号, 医保个人编号, 医保卡号, 备案时间, 备案地, 工作地点, 工种, 备注, 公主岭合同起止时间, 公主岭社保个人编号, 公主岭医保个人编号, 办理解除时间, 社保解除时间, 医保解除时间

    last_row = sheet.last_row
    (2..last_row).each do |row_id|
      puts "... Processing #{row_id}/#{last_row}" if row_id % 50 == 0

      nest_index, name, corporation_id, corporation_name, identity_card, age, gender, nation, grade, address, telephone, social_insurance_start_date, current_social_insurance_start_date, current_medical_insurance_start_date, arrive_current_company_at, dongfang_siping_contract_dates, current_contract_dates, social_insurance_serial, medical_insurance_serial, medical_insurance_card, backup_date, backup_place, work_place, work_type, remark, dongfang_gongzhuling_contract_dates, dongfang_gongzhuling_social_insurance_serial, dongfang_gongzhuling_medical_insurance_serial, release_date, social_insurance_release_date, medical_insurance_release_date = \
        sheet.row(row_id).map{|col| String === col ? col.strip : col}

      in_service = false
      contract_type = :normal_contract

      begin
        normal_corporation_id = NormalCorporation.find_or_create_by!(name: corporation_name).id
        raise "未找到合作单位(名称: #{corporation_name})" if normal_corporation_id.nil?

        # Need to confirm
        #
        #   :account
        #   :account_bank
        #   :birth
        ns = NormalStaff.create!(
          nest_index: nest_index.to_i,
          name: name,
          account: nil,
          account_bank: nil,
          identity_card: identity_card.to_s,
          birth: nil,
          age: age,
          gender: {'男' => 'male', '女' => 'female'}[gender],
          nation: nation,
          grade: grade,
          address: address,
          telephone: telephone.to_s,
          social_insurance_start_date: parse_date(social_insurance_start_date),
          in_service: in_service,
          remark: remark,
          normal_corporation_id: normal_corporation_id,
          sub_company_id: sub_company_id
        )

        # Need to confirm
        #
        #   :has_accident_insurance
        #   :social_insurance_base
        #   :medical_insurance_base
        #   :house_accumulation_base
        #   :release_date
        contract_attrs = {
          contract_type: contract_type,
          in_contract: false,
          contract_start_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 0)),
          contract_end_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 1)),
          arrive_current_company_at: parse_date(arrive_current_company_at),
          has_social_insurance: true,
          has_medical_insurance: true,
          has_accident_insurance: nil,
          current_social_insurance_start_date: parse_date(current_social_insurance_start_date),
          current_medical_insurance_start_date: parse_date(current_medical_insurance_start_date),
          social_insurance_base: nil.to_i,
          medical_insurance_base: nil.to_i,
          house_accumulation_base: nil.to_i,
          social_insurance_serial: social_insurance_serial.to_s,
          medical_insurance_serial: medical_insurance_serial.to_s,
          medical_insurance_card: medical_insurance_card.to_s,
          backup_date: parse_date(backup_date),
          backup_place: backup_place,
          work_place: work_place,
          work_type: work_type,
          release_date: release_date,
          social_insurance_release_date: parse_date(social_insurance_release_date),
          medical_insurance_release_date: parse_date(medical_insurance_release_date),
          remark: nil,
          sub_company_id: sub_company_id,
          normal_corporation_id: normal_corporation_id,
          normal_staff_id: ns.id,
        }

        # Create current contract
        LaborContract.create!(contract_attrs)

        # Create dongfang siping contract
        if dongfang_siping_contract_dates.present?
          contract_attrs_siping = contract_attrs.merge({
            in_contract: false,
            contract_start_date: parse_date(dongfang_siping_contract_dates.split('-')[0]),
            contract_end_date: parse_date(dongfang_siping_contract_dates.split('-')[1]),
          })
          LaborContract.create!(contract_attrs_siping)
        end

        # Create dongfang gongzhuling contract
        if dongfang_gongzhuling_contract_dates.present?
          contract_attrs_gongzhuling = contract_attrs.merge({
            in_contract: false,
            contract_start_date: parse_date(dongfang_gongzhuling_contract_dates.split('-')[0]),
            contract_end_date: parse_date(dongfang_gongzhuling_contract_dates.split('-')[1]),
            social_insurance_serial: dongfang_gongzhuling_social_insurance_serial,
            medical_insurance_serial: dongfang_gongzhuling_medical_insurance_serial
          })
          LaborContract.create!(contract_attrs_gongzhuling)
        end
      rescue => e
        failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
      end

    end


    sheet_id = 2
    sheet = xlsx.sheet(sheet_id)
    puts "--> Start processing Sheet #{sheet_id}"

    # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 性别, 年龄, 家庭住址, 联系电话, 到本单位时间, 签订合同时间, 工作地点, 工种, 协议类型

    last_row = sheet.last_row
    (2..last_row).each do |row_id|
      puts "... Processing #{row_id}/#{last_row}" if row_id % 50 == 0

      nest_index, name, corporation_id, corporation_name, identity_card, gender, age, address, telephone, arrive_current_company_at, current_contract_dates, work_place, work_type, contract_type = \
        sheet.row(row_id).map{|col| String === col ? col.strip : col}

      nation, grade, social_insurance_start_date, remark = [nil] * 4
      in_service = true

      begin
        normal_corporation_id = NormalCorporation.find_or_create_by!(name: corporation_name).id
        raise "未找到合作单位(名称: #{corporation_name})" if normal_corporation_id.nil?

        # Need to confirm
        #
        #   :account
        #   :account_bank
        #   :birth
        ns = NormalStaff.create!(
          nest_index: nest_index.to_i,
          name: name,
          account: nil,
          account_bank: nil,
          identity_card: identity_card.to_s,
          birth: nil,
          age: age,
          gender: {'男' => 'male', '女' => 'female'}[gender],
          nation: nation,
          grade: grade,
          address: address,
          telephone: telephone.to_s,
          social_insurance_start_date: parse_date(social_insurance_start_date),
          in_service: in_service,
          remark: remark,
          normal_corporation_id: normal_corporation_id,
          sub_company_id: sub_company_id
        )

        contract_type = parse_contract_type(contract_type)

        # Need to confirm
        #
        #   :has_accident_insurance
        #   :social_insurance_base
        #   :medical_insurance_base
        #   :house_accumulation_base
        #   :release_date
        #   :social_insurance_release_date
        #   :medical_insurance_release_date
        contract_attrs = {
          contract_type: contract_type,
          in_contract: true,
          contract_start_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 0)),
          contract_end_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 1)),
          arrive_current_company_at: parse_date(arrive_current_company_at),
          has_social_insurance: false,
          has_medical_insurance: false,
          has_accident_insurance: nil,
          current_social_insurance_start_date: nil,
          current_medical_insurance_start_date: nil,
          social_insurance_base: nil.to_i,
          medical_insurance_base: nil.to_i,
          house_accumulation_base: nil.to_i,
          social_insurance_serial: nil,
          medical_insurance_serial: nil,
          medical_insurance_card: nil,
          backup_date: nil,
          backup_place: nil,
          work_place: work_place,
          work_type: work_type,
          release_date: nil,
          social_insurance_release_date: nil,
          medical_insurance_release_date: nil,
          remark: nil,
          sub_company_id: sub_company_id,
          normal_corporation_id: normal_corporation_id,
          normal_staff_id: ns.id,
        }

        # Create current contract
        LaborContract.create!(contract_attrs)

      rescue => e
        failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
      end
    end

    sheet_id = 3
    sheet = xlsx.sheet(sheet_id)
    puts "--> Start processing Sheet #{sheet_id}"

    # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 性别, 年龄, 家庭住址, 联系电话, 到本单位时间, 签订合同时间, 工作地点, 工种, 协议类型

    last_row = sheet.last_row
    (2..last_row).each do |row_id|
      puts "... Processing #{row_id}/#{last_row}" if row_id % 50 == 0

      nest_index, name, corporation_id, corporation_name, identity_card, gender, age, address, telephone, arrive_current_company_at, current_contract_dates, work_place, work_type, contract_type = \
        sheet.row(row_id).map{|col| String === col ? col.strip : col}

      nation, grade, social_insurance_start_date, remark = [nil] * 4
      in_service = true

      begin
        normal_corporation_id = NormalCorporation.find_or_create_by!(name: corporation_name).id
        raise "未找到合作单位(名称: #{corporation_name})" if normal_corporation_id.nil?

        # Need to confirm
        #
        #   :account
        #   :account_bank
        #   :birth
        ns = NormalStaff.create!(
          nest_index: nest_index.to_i,
          name: name,
          account: nil,
          account_bank: nil,
          identity_card: identity_card.to_s,
          birth: nil,
          age: age,
          gender: {'男' => 'male', '女' => 'female'}[gender],
          nation: nation,
          grade: grade,
          address: address,
          telephone: telephone.to_s,
          social_insurance_start_date: parse_date(social_insurance_start_date),
          in_service: in_service,
          remark: remark,
          normal_corporation_id: normal_corporation_id,
          sub_company_id: sub_company_id
        )

        contract_type = :none_contract

        # Need to confirm
        #
        #   :has_accident_insurance
        #   :social_insurance_base
        #   :medical_insurance_base
        #   :house_accumulation_base
        #   :release_date
        #   :social_insurance_release_date
        #   :medical_insurance_release_date
        contract_attrs = {
          contract_type: contract_type,
          in_contract: true,
          contract_start_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 0)),
          contract_end_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 1)),
          arrive_current_company_at: parse_date(arrive_current_company_at),
          has_social_insurance: false,
          has_medical_insurance: false,
          has_accident_insurance: nil,
          current_social_insurance_start_date: nil,
          current_medical_insurance_start_date: nil,
          social_insurance_base: nil.to_i,
          medical_insurance_base: nil.to_i,
          house_accumulation_base: nil.to_i,
          social_insurance_serial: nil,
          medical_insurance_serial: nil,
          medical_insurance_card: nil,
          backup_date: nil,
          backup_place: nil,
          work_place: work_place,
          work_type: work_type,
          release_date: nil,
          social_insurance_release_date: nil,
          medical_insurance_release_date: nil,
          remark: nil,
          sub_company_id: sub_company_id,
          normal_corporation_id: normal_corporation_id,
          normal_staff_id: ns.id,
        }

        # Create current contract
        LaborContract.create!(contract_attrs)

      rescue => e
        failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
      end
    end

    if failed.any?(&:present?)
      filename = "#{file.basename.to_s.split('.')[0]}.#{Time.stamp}.xlsx"
      filepath = Pathname("tmp/#{filename}")

      Axlsx::Package.new do |p|
        failed.each_with_index do |failed_sheet, i|
          p.workbook.add_worksheet(name: xlsx.sheets[i]) do |sheet|
            sheet.add_row xlsx.sheet(i).row(1)
            failed_sheet.each{|stat| sheet.add_row stat}
          end
        end
        p.serialize(filepath.to_s)
      end

      puts "--> Generate failed file: #{filepath.expand_path}"
      `open #{filepath.expand_path}`
    else
      puts "--> Bravo, Succeed!"
    end


    # sheet = xlsx.sheet(1)
    # sheet = xlsx.sheet(2)
    # sheet = xlsx.sheet(3)
  end

  private

    def load_rails
      require File.expand_path('config/environment.rb')
    end

    def parse_date(str)
      str = str.to_s
      str = str << ".1" if str.split('.').count == 2
      str.gsub!('－', '-')

      Date.parse(str) rescue nil
    end

    def parse_contract_type(str)
      case str.to_s.strip
      when /^退休/
        :retire_contract
      when /^临时/
        :temp_contract
      when /^非全日/
        :none_full_day_contract
      else
        :none_contract
      end
    end
end

Import.start(ARGV)
