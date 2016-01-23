require_relative 'duoduo_cli'

class BusinessStaff < DuoduoCli
  attr_reader :file, :sub_company, :xlsx, :failed

  desc "start", "导入信息到员工档案和劳务合同"
  long_desc <<-LONG_DESC
    Example

      ruby lib/tasks/business_staff.rb start --from=tmp/import/staff_and_contract/吉易通讯公司.xls

    Dependency

      1. Already seed SubCompany, NormalCorporation
      2. 文件名称需为子公司名称, eg. 吉易通讯公司.xls

  LONG_DESC
  option :from, required: true # 文件名为子公司名称
  def start
    load_rails
    clean_db(:business_staff)
    clean_logger
    init_logger

    logger.info "[#{Time.now}] Import start"

    path = load_from(options[:from])
    if path.directory?
      files = path.entries.reject{|en| en.to_s.start_with?('.')}.map{|en| path.join(en)}
    else
      files = Array.wrap(path)
    end

    $NULL_ID = 111111111111111111
    files.each do |f|
      logger.info "#{f.basename}"

      set_file(f)
      set_sub_company
      parse_file
    end

    logger.info "[#{Time.now}] Import end"
  end

  private

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

    def set_file(path)
      @file = path
    end

    def set_sub_company
      name = file.basename.to_s.split('.')[0].strip

      @sub_company = SubCompany.where(name: name).first
      raise "未找到子公司(名称: #{name})。请保证 from 文件名为子公司名" if @sub_company.nil?
    end

    def parse_file
      set_xlsx
      set_failed

      process_first_sheet
      process_second_sheet
      process_third_sheet
      process_fourth_sheet

      process_failed
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def set_failed
      @failed = [ [], [], [], [] ]
    end

    def get_right_corporation_name(name, work_type = nil)
      return '内部' if name.index '内部'

      if sub_company.name == '吉易通讯公司'
        if name == '铁通'
          '铁通（通讯）'
        elsif name.index('联通') && work_type.present?
          if work_type =~ /线务/
            name.gsub('联通', '') + '线务'
          elsif work_type =~ /话务/
            name.gsub('联通', '') + '话务'
          elsif work_type =~ /营业/
            name.gsub('联通', '') + '营业'
          else
            name
          end
        else
          name
        end
      elsif sub_company.name == '吉易人力资源'
        if name == '铁通'
          '铁通（人力）'
        elsif name == '铁东地税'
          '铁东地税（人力）'
        elsif name == '铁西地税'
          '铁西地税（人力）'
        else
          name
        end
      elsif sub_company.name == '吉易企业管理'
        if name == '铁塔公司'
          '铁塔公司（企业管理）'
        else
          name
        end
      elsif sub_company.name == '吉易物业公司'
        if name == '铁通'
          '铁通（物业）'
        elsif name == '铁塔公司'
          '铁塔公司（物业）'
        elsif name == '铁西地税'
          '铁西地税（物业）'
        elsif name == '铁东地税'
          '铁东地税（物业）'
        else
          name
        end
      elsif sub_company.name == '百奕劳务公司'
        if name == '铁通'
          '铁通（百奕）'
        end
      else
        name
      end
    end

    def process_first_sheet
      sheet_id = 0
      sheet = xlsx.sheet(sheet_id)
      # logger.info "--> Start processing Sheet #{sheet_id}"

      in_service = true
      contract_type = :normal_contract

      # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 年龄, 性别, 民族, 学历, 家庭住址, 联系电话, 社保参加工作时间, 本单位社保参保时间, 本单位医保参保时间, 到本单位时间, 四平东方合同起止时间, 通讯合同起止时间, 社保个人编号, 医保个人编号, 医保卡号, 备案时间, 备案地, 工作地点, 工种, 备注, 公主岭合同起止时间, 公主岭社保个人编号, 公主岭医保个人编号, 百奕续签合同起止时间(option)

      last_row = sheet.last_row
      return if last_row.nil?

      (2..last_row).each do |row_id|
        # logger.info "... Processing #{row_id}/#{last_row}" if row_id % 100 == 0

        nest_index, name, _corporation_id, corporation_name, identity_card, age, gender, nation, grade, address, telephone, social_insurance_start_date, current_social_insurance_start_date, current_medical_insurance_start_date, arrive_current_company_at, dongfang_siping_contract_dates, current_contract_dates, current_contract_dates_cont, social_insurance_serial, medical_insurance_serial, medical_insurance_card, backup_date, backup_place, work_place, work_type, remark, dongfang_gongzhuling_contract_dates, dongfang_gongzhuling_social_insurance_serial, dongfang_gongzhuling_medical_insurance_serial, baiyi_once_contract_dates = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        next if nest_index.nil?

        begin
          corp_name = get_right_corporation_name(corporation_name, work_type)
          normal_corporation_id = NormalCorporation.where(name: corp_name).first.try(:id)
          # normal_corporation_id = sub_company.normal_corporations.find_or_create_by!(name: corporation_name).id
          logger.error "#{sub_company.name} ; #{xlsx.sheets[sheet_id]} ; #{name} ; 未找到合作单位 ; #{corporation_name}" if normal_corporation_id.nil?

          identity_card = identity_card.to_s.strip
          if identity_card.to_s == '111111111111111111'
            $NULL_ID += 1
            identity_card = $NULL_ID.to_s
          end

          # Need to confirm
          #
          #   :account
          #   :account_bank
          ns = NormalStaff.where(identity_card: identity_card).first
          ns ||= NormalStaff.create!(
            nest_index: nest_index.to_i,
            name: name,
            account: nil,
            account_bank: nil,
            identity_card: identity_card,
            gender: {'男' => 'male', '女' => 'female'}[gender],
            nation: nation,
            grade: grade,
            address: address,
            telephone: Numeric === telephone ? telephone.to_i.to_s : telephone.to_s,
            social_insurance_start_date: parse_date(social_insurance_start_date),
            in_service: in_service,
            remark: remark,
            normal_corporation_id: normal_corporation_id,
            sub_company_id: sub_company.id
          )

          social_insurance_base = 1861.15
          medical_insurance_base = 3102
          house_accumulation_base = 0

          # Need to confirm
          #
          #   :has_accident_insurance
          #   :release_date
          #   :social_insurance_release_date
          #   :medical_insurance_release_date
          in_contract = current_contract_dates_cont.blank?
          contract_attrs = {
            contract_type: contract_type,
            in_contract: in_contract,
            contract_start_date: parse_date(current_contract_dates.split('-')[0]),
            contract_end_date: parse_date(current_contract_dates.split('-')[1]),
            arrive_current_company_at: parse_date(arrive_current_company_at),
            has_social_insurance: true,
            has_medical_insurance: true,
            has_accident_insurance: nil,
            current_social_insurance_start_date: parse_date(current_social_insurance_start_date),
            current_medical_insurance_start_date: parse_date(current_medical_insurance_start_date),
            social_insurance_base: social_insurance_base,
            medical_insurance_base: medical_insurance_base,
            house_accumulation_base: house_accumulation_base,
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
            normal_corporation_id: normal_corporation_id,
            normal_staff_id: ns.id,
          }

          # Create current contract
          LaborContract.create!(contract_attrs)

          # Add a cont contract
          if current_contract_dates_cont.present?
            LaborContract.create!(contract_attrs.merge({in_contract: true}))
          end

          # Create dongfang siping contract
          if dongfang_siping_contract_dates.present?
            contract_start_date, contract_end_date = dongfang_siping_contract_dates.split('-').map{|d| parse_date(d)}
            contract_attrs_siping = contract_attrs.merge({
              in_contract: false,
              contract_start_date: contract_start_date,
              contract_end_date: contract_end_date,
              remark: '东方'
            })
            LaborContract.create!(contract_attrs_siping)
          end

          # Create dongfang gongzhuling contract
          if dongfang_gongzhuling_contract_dates.present?
            contract_start_date, contract_end_date = dongfang_gongzhuling_contract_dates.split('-').map{|d| parse_date(d)} rescue nil
            contract_attrs_gongzhuling = contract_attrs.merge({
              in_contract: false,
              contract_start_date: contract_start_date,
              contract_end_date: contract_end_date,
              social_insurance_serial: dongfang_gongzhuling_social_insurance_serial,
              medical_insurance_serial: dongfang_gongzhuling_medical_insurance_serial,
              remark: '公主岭'
            })
            LaborContract.create!(contract_attrs_gongzhuling)
          end

          if baiyi_once_contract_dates.present?
            contract_start_date, contract_end_date = baiyi_once_contract_dates.split('-').map{|d| parse_date(d)}
            contract_attrs_gongzhuling = contract_attrs.merge({
              in_contract: false,
              contract_start_date: contract_start_date,
              contract_end_date: contract_end_date,
              remark: '百奕'
            })
            LaborContract.create!(contract_attrs_gongzhuling)
          end
        rescue => e
          failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
        end
      end

    end

    def process_second_sheet
      sheet_id = 1
      sheet = xlsx.sheet(sheet_id)
      # logger.info "--> Start processing Sheet #{sheet_id}"

      in_service = true
      in_contract = false
      contract_type = :normal_contract

      # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 年龄, 性别, 民族, 学历, 家庭住址, 联系电话, 社保参加工作时间, 本单位社保参保时间, 本单位医保参保时间, 到本单位时间, 四平东方合同起止时间, 通讯合同起止时间 , 社保个人编号, 医保个人编号, 医保卡号, 备案时间, 备案地, 工作地点, 工种, 备注, 公主岭合同起止时间, 公主岭社保个人编号, 公主岭医保个人编号, 办理解除时间, 社保解除时间, 医保解除时间

      last_row = sheet.last_row
      return if last_row.nil?

      (2..last_row).each do |row_id|
        # logger.info "... Processing #{row_id}/#{last_row}" if row_id % 100 == 0

        nest_index, name, _corporation_id, corporation_name, identity_card, age, gender, nation, grade, address, telephone, social_insurance_start_date, current_social_insurance_start_date, current_medical_insurance_start_date, arrive_current_company_at, dongfang_siping_contract_dates, current_contract_dates, social_insurance_serial, medical_insurance_serial, medical_insurance_card, backup_date, backup_place, work_place, work_type, remark, dongfang_gongzhuling_contract_dates, dongfang_gongzhuling_social_insurance_serial, dongfang_gongzhuling_medical_insurance_serial, release_date, social_insurance_release_date, medical_insurance_release_date = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        next if nest_index.nil?

        begin
          corp_name = get_right_corporation_name(corporation_name, work_type)
          normal_corporation_id = NormalCorporation.where(name: corp_name).first.try(:id)
          # normal_corporation_id = sub_company.normal_corporations.find_or_create_by!(name: corporation_name).id
          logger.error "#{sub_company.name} ; #{xlsx.sheets[sheet_id]} ; #{name} ; 未找到合作单位 ; #{corporation_name}" if normal_corporation_id.nil?

          identity_card = identity_card.to_s.strip
          if identity_card.to_s == '111111111111111111'
            $NULL_ID += 1
            identity_card = $NULL_ID.to_s
          end

          # Need to confirm
          #
          #   :account
          #   :account_bank
          ns = NormalStaff.where(identity_card: identity_card).first
          ns ||= NormalStaff.create!(
            nest_index: nest_index.to_i,
            name: name,
            account: nil,
            account_bank: nil,
            identity_card: identity_card,
            gender: {'男' => 'male', '女' => 'female'}[gender],
            nation: nation,
            grade: grade,
            address: address,
            telephone: Numeric === telephone ? telephone.to_i.to_s : telephone.to_s,
            social_insurance_start_date: parse_date(social_insurance_start_date),
            in_service: in_service,
            remark: remark,
            normal_corporation_id: normal_corporation_id,
            sub_company_id: sub_company.id
          )

          social_insurance_base = 1861.15
          medical_insurance_base = 3102
          house_accumulation_base = 0

          # Need to confirm
          #
          #   :has_accident_insurance
          #   :release_date
          contract_attrs = {
            contract_type: contract_type,
            in_contract: in_contract,
            contract_start_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 0)),
            contract_end_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 1)),
            arrive_current_company_at: parse_date(arrive_current_company_at),
            has_social_insurance: true,
            has_medical_insurance: true,
            has_accident_insurance: nil,
            current_social_insurance_start_date: parse_date(current_social_insurance_start_date),
            current_medical_insurance_start_date: parse_date(current_medical_insurance_start_date),
            social_insurance_base: social_insurance_base,
            medical_insurance_base: medical_insurance_base,
            house_accumulation_base: house_accumulation_base,
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
              remark: '东方'
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
              medical_insurance_serial: dongfang_gongzhuling_medical_insurance_serial,
              remark: '公主岭'
            })
            LaborContract.create!(contract_attrs_gongzhuling)
          end
        rescue => e
          failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
        end

      end
    end

    def process_third_sheet
      sheet_id = 2
      sheet = xlsx.sheet(sheet_id)
      # logger.info "--> Start processing Sheet #{sheet_id}"

      in_service = true

      # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 性别, 年龄, 家庭住址, 联系电话, 到本单位时间, 签订合同时间, 工作地点, 工种, 协议类型, 备注

      last_row = sheet.last_row
      return if last_row.nil?

      (2..last_row).each do |row_id|
        # logger.info "... Processing #{row_id}/#{last_row}" if row_id % 100 == 0

        nest_index, name, _corporation_id, corporation_name, identity_card, gender, age, address, telephone, arrive_current_company_at, current_contract_dates, work_place, work_type, contract_type, remark = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        nation, grade, social_insurance_start_date = [nil] * 3

        next if nest_index.nil?

        begin
          corp_name = get_right_corporation_name(corporation_name, work_type)
          normal_corporation_id = NormalCorporation.where(name: corp_name).first.try(:id)
          # normal_corporation_id = sub_company.normal_corporations.find_or_create_by!(name: corporation_name).id
          logger.error "#{sub_company.name} ; #{xlsx.sheets[sheet_id]} ; #{name} ; 未找到合作单位 ; #{corporation_name}" if normal_corporation_id.nil?

          identity_card = identity_card.to_s.strip
          if identity_card.to_s == '111111111111111111'
            $NULL_ID += 1
            identity_card = $NULL_ID.to_s
          end

          # Need to confirm
          #
          #   :account
          #   :account_bank
          ns = NormalStaff.where(identity_card: identity_card).first
          ns ||= NormalStaff.create!(
            nest_index: nest_index.to_i,
            name: name,
            account: nil,
            account_bank: nil,
            identity_card: identity_card,
            gender: {'男' => 'male', '女' => 'female'}[gender],
            nation: nation,
            grade: grade,
            address: address,
            telephone: Numeric === telephone ? telephone.to_i.to_s : telephone.to_s,
            social_insurance_start_date: parse_date(social_insurance_start_date),
            in_service: in_service,
            remark: remark,
            normal_corporation_id: normal_corporation_id,
            sub_company_id: sub_company.id
          )

          contract_type = parse_contract_type(contract_type)
          social_insurance_base = 1861.15
          medical_insurance_base = 3102
          house_accumulation_base = 0

          # Need to confirm
          #
          #   :has_accident_insurance
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
            social_insurance_base: social_insurance_base,
            medical_insurance_base: medical_insurance_base,
            house_accumulation_base: house_accumulation_base,
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
            normal_corporation_id: normal_corporation_id,
            normal_staff_id: ns.id,
          }

          # Create current contract
          LaborContract.create!(contract_attrs)

        rescue => e
          failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
        end
      end
    end

    def process_fourth_sheet
      sheet_id = 3
      sheet = xlsx.sheet(sheet_id)
      # logger.info "--> Start processing Sheet #{sheet_id}"

      in_service = true

      # 档案编号, 姓名, 单位编号, 公司名称, 身份证号, 性别, 年龄, 家庭住址, 联系电话, 到本单位时间, 签订合同时间, 工作地点, 工种, 协议类型, 备注

      last_row = sheet.last_row
      return if last_row.nil?

      (2..last_row).each do |row_id|
        logger.info "... Processing #{row_id}/#{last_row}" if row_id % 100 == 0

        nest_index, name, _corporation_id, corporation_name, identity_card, gender, age, address, telephone, arrive_current_company_at, current_contract_dates, work_place, work_type, contract_type, remark = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        nation, grade, social_insurance_start_date = [nil] * 3

        next if nest_index.nil?

        begin
          corp_name = get_right_corporation_name(corporation_name, work_type)
          normal_corporation_id = NormalCorporation.where(name: corp_name).first.try(:id)
          # normal_corporation_id = sub_company.normal_corporations.find_or_create_by!(name: corporation_name).id
          logger.error "#{sub_company.name} ; #{xlsx.sheets[sheet_id]} ; #{name} ; 未找到合作单位 ; #{corporation_name}" if normal_corporation_id.nil?

          identity_card = identity_card.to_s.strip
          if identity_card.to_s == '111111111111111111'
            $NULL_ID += 1
            identity_card = $NULL_ID.to_s
          end

          # Need to confirm
          #
          #   :account
          #   :account_bank
          ns = NormalStaff.where(identity_card: identity_card).first
          ns ||= NormalStaff.create!(
            nest_index: nest_index.to_i,
            name: name,
            account: nil,
            account_bank: nil,
            identity_card: identity_card,
            gender: {'男' => 'male', '女' => 'female'}[gender],
            nation: nation,
            grade: grade,
            address: address,
            telephone: Numeric === telephone ? telephone.to_i.to_s : telephone.to_s,
            social_insurance_start_date: parse_date(social_insurance_start_date),
            in_service: in_service,
            remark: remark,
            normal_corporation_id: normal_corporation_id,
            sub_company_id: sub_company.id
          )

          # contract_type = :none_contract
          contract_type = parse_contract_type(contract_type)
          social_insurance_base = 1861.15
          medical_insurance_base = 3102
          house_accumulation_base = 0

          # Need to confirm
          #
          #   :has_accident_insurance
          #   :release_date
          #   :social_insurance_release_date
          #   :medical_insurance_release_date
          contract_attrs = {
            contract_type: contract_type,
            in_contract: false,
            contract_start_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 0)),
            contract_end_date: parse_date(current_contract_dates.try(:split, '-').try(:[], 1)),
            arrive_current_company_at: parse_date(arrive_current_company_at),
            has_social_insurance: false,
            has_medical_insurance: false,
            has_accident_insurance: nil,
            current_social_insurance_start_date: nil,
            current_medical_insurance_start_date: nil,
            social_insurance_base: social_insurance_base,
            medical_insurance_base: medical_insurance_base,
            house_accumulation_base: house_accumulation_base,
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
            normal_corporation_id: normal_corporation_id,
            normal_staff_id: ns.id,
          }

          # Create current contract
          LaborContract.create!(contract_attrs)

        rescue => e
          failed[sheet_id] << sheet.row(row_id) + [e.message, e.backtrace]
        end
      end

    end

    def process_failed
      if failed.any?(&:present?)
        filename = "#{file.basename.to_s.split('.')[0]}.#{Time.stamp}.xlsx"
        filepath = Pathname("tmp/#{filename}")

        Axlsx::Package.new do |p|
          failed.each_with_index do |failed_sheet, i|
            p.workbook.add_worksheet(name: xlsx.sheets[i]) do |sheet|
              next if failed_sheet.blank?
              sheet.add_row xlsx.sheet(i).row(1)
              failed_sheet.each{|stat| stat[4] = "\"#{stat[4]}\""; sheet.add_row(stat) }
            end
          end
          p.serialize(filepath.to_s)
        end

        logger.info "*** Generate failed file: #{filepath.expand_path}"
        # `open #{filepath.expand_path}`
      else
        logger.info "*** Bravo, Succeed!"
      end
    end
end

BusinessStaff.start(ARGV)
