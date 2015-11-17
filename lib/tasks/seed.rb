require 'thor'

class Seed < Thor
  desc "base", ''
  def base
    load_rails
    clean_db

    seed_admin_user
    seed_sub_companies
  end

  desc "engineering", "Import engineering data"
  option :from, required: true
  def engineering
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])
    customer_dir = Pathname(options[:from])

    # load_rails
    base

    customer = EngineeringCustomer.find_or_create_by!(name: customer_dir.basename.to_s)

    puts "- #{customer_dir.basename}"

    infos = customer_dir.entries.select{|pn| pn.to_s =~ /信息汇总/ }
    raise "没有信息汇总" if infos.blank?
    projects = {}
    infos.each do |info|
      stats = handling_project_info(file: customer_dir.join(info), customer: customer)
      projects.merge!(stats)
    end

    customer_dir.entries.each do |pn|
      next if pn.to_s.start_with?('.') or pn.to_s =~ /信息汇总/ or pn.to_s.start_with?('skip')
      puts "--- #{pn}"

      id, _name = pn.to_s.split('、')
      raise "项目#{pn}不在信息汇总中" if projects[id.to_i].nil?
      project = projects[id.to_i]

      staff_file = customer_dir.join(pn).entries.detect{|file| file.to_s =~ /用工/}
      next if staff_file.nil?
      puts "----- #{staff_file.to_s}"
      path = customer_dir.join(pn).join(staff_file)
      handling_staff(path: path, project: project)

      customer_dir.join(pn).entries.each do |file|
        next if file.to_s.start_with?('.') or file.to_s =~ /用工/
        puts "----- #{file.to_s}"

        path = customer_dir.join(pn).join(file)

        if file.to_s =~ /合同/
          project.add_contract_file(path: path, role: :normal)
        elsif file.to_s =~ /协议/
          project.add_contract_file(path: path, role: :proxy)
        elsif file.to_s =~ /工资/
          handling_salary_table(path: path, project: project, type: :normal)
        else
          fail "Unknow file name: #{file}"
        end
      end
    end
  end

  private

    def get_sub_company_by(name:)
      if name.index('东方')
        SubCompany.query_name('东方').first
      elsif name.index('人力分') || name.index('公主岭')
        SubCompany.query_name('公主岭').first
      elsif name.index('人力')
        SubCompany.where(name: '吉易人力资源').first
      else
        fail "Failed parsing SubCompany name: #{name}"
      end
    end

    def load_rails
      puts "==> Loading Rails"
      require File.expand_path('config/environment.rb')
    end

    def clean_db
      puts "==> Cleaning DB data"
      [
        LaborContract,
        SalaryItem, Invoice, SalaryTable,
        GuardSalaryItem, GuardSalaryTable,
        NonFullDaySalaryItem, NonFullDaySalaryTable,
        NormalStaff, NormalCorporation,
        ContractFile, SubCompany,
        InsuranceFundRate, IndividualIncomeTaxBase, IndividualIncomeTax,
        EngineeringSalaryTable,
        EngineeringStaff, EngineeringProject, EngineeringCorp, EngineeringCustomer,
        EngineeringCompanySocialInsuranceAmount, EngineeringCompanyMedicalInsuranceAmount
      ].each(&:destroy_all)
    end

    def seed_admin_user
      if AdminUser.where(email: 'admin').first.nil?
        au = AdminUser.new(email: 'admin', password: '123123', password_confirmation: '123123')
        au.save(validate: false)
      end
    end

    def seed_sub_companies
      puts "==> Preparing SubCompany"
      Rails.application.secrets.sub_company_names.each_with_object([]) do |name, companies|
        has_engineering_relation = (name =~ /人力/ ? true : false)
        sc = SubCompany.create(name: name, has_engineering_relation: has_engineering_relation)

        # TODO
        #   - Set contract and template files
        # (1..2).each_with_object([]) do |idx, ar|
        #   if File.exist?(("tmp/#{name}.合同#{idx}.txt"))
        #     contract = "tmp/#{name}.合同#{idx}.txt"
        #     sc.contract_files.create(contract: File.open(contract) )
        #     sc.add_file(contract, template: true)
        #   end
        # end

        companies << sc
      end
    end

    def parse_project_dates(str)
      fail "Invalid project dates: #{str}" if str.split('-').count > 2

      start_date, end_date = str.split('-')

      start_date = revise_date start_date

      if end_date.nil?
        end_date = start_date.end_of_month
      else
        year = start_date.year

        parts = end_date.split('.')

        if parts[0].to_i > 12
          parts[0] = "20#{parts[0]}"
        elsif parts[0].length != 4
          parts.unshift year
        end

        end_date = revise_date(parts.join('.'))
        end_date = end_date.end_of_month if end_date.day == 1
      end

      [start_date, end_date]
    end

    # 2015.4
    def revise_date(date)
      parts = date.split('.')
      parts << '1' if parts.count == 2

      begin
        Date.parse parts.join('.')
      rescue => e
        puts "revise_date: Invalid date: #{date}"
        puts e.backtrace
        raise e
      end
    end

    # 处理信息汇总
    def handling_project_info(file:, customer:)

      puts "--- #{file.basename}"

      sc = get_sub_company_by(name: file.basename.to_s)
      customer.sub_companies << sc

      xlsx_name = file.to_s
      xlsx = Roo::Spreadsheet.open(xlsx_name)
      sheet_id = 0
      sheet = xlsx.sheet(sheet_id)

      last_row = sheet.last_row
      col_count = sheet.row(2).compact.count
      projects = {}
      (3..last_row).each do |row_id|
        data = sheet.row(row_id)
        next if data[0].nil?
        if data[0] == '合计'
          data = data.compact
          total = {
            project_amount: data[1],
            admin_amount: data[2],
            total_amount: data[3],
            outcome_amount: data[4]
          }
          total.each do |k,v|
            puts "----- Validation failed: unequal #{k} total in #{xlsx_name}" unless total[k].to_f == projects.values.map(&k).map(&:to_f).sum
          end

          break
        end

        if col_count == 14
          id, start_date, project_dates, name, project_amount, admin_amount, _project_amount, _admin_amount, total_amount, income_date, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            sheet.row(row_id).map{|col| String === col ? col.strip : col}
        elsif col_count == 12 || col_count == 11
          id, start_date, project_dates, name, project_amount, admin_amount, total_amount, income_date, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            sheet.row(row_id).map{|col| String === col ? col.strip : col}
        else
          fail "无法解析信息汇总：#{file}"
        end

        project_start_date, project_end_date = parse_project_dates(project_dates)
        project = customer.engineering_projects.create!(
          name: "#{id.to_i}、#{name}",
          start_date: start_date,
          project_start_date: project_start_date,
          project_end_date: project_end_date,
          project_amount: project_amount,
          admin_amount: admin_amount,
          income_date: income_date,
          outcome_date: outcome_date,
          outcome_referee: outcome_referee,
          outcome_amount: outcome_amount,
          proof: proof,
          remark: remark
        )

        fail "Validation failed: unequal project total_amount: #{id}" if project.total_amount != total_amount.to_f

        projects[id.to_i] = project
      end

      projects
    end

    def handling_staff(path: , project:)
      xlsx_name = path.to_s
      xlsx = Roo::Spreadsheet.open(xlsx_name)
      sheet_id = 0
      sheet = xlsx.sheet(sheet_id)

      last_row = sheet.last_row

      (3..last_row).each do |row_id|
        _id, name, gender, identity_card = sheet.row(row_id).map{|col| String === col ? col.strip : col}
        next if _id.nil?

        gender_map = {'男' => :male, '女' => :female}
        staff = EngineeringStaff.find_or_create_by!(
          engineering_customer: project.engineering_customer,
          name: name,
          gender: gender_map[gender],
          identity_card: identity_card
        )
        staff.engineering_projects << project
      end
    end

    def handling_salary_table(path:, project:, type:)
      type = case type
             when :with_tax
               'EngineeringNormalWithTaxSalaryTable'
             when :big_table
               'EngineeringBigTableSalaryTable'
             when :dong_fang
               'EngineeringDongFangSalaryTable'
             else
               'EngineeringNormalSalaryTable'
             end

      xlsx_name = path.to_s
      xlsx = Roo::Spreadsheet.open(xlsx_name)

      xlsx.sheets.each_index do |sheet_id|
        puts "------- Sheet #{sheet_id+1}"
        sheet = xlsx.sheet(sheet_id)

        begin
          if sheet.row(2).compact.count == 1
            name = sheet.row(2)[0].match(/(\d*年\d*月)./)[1]
            start_row = 4
          elsif sheet.row(1).compact.count == 1
            name = sheet.row(1)[0].match(/(\d+年\(?\d*\)?月)/)[1]
            start_row = 3
          else
            fail "无法解析工资表名称: #{path}"
          end
        rescue => _
          fail "无法解析工资表名称: #{path}"
        end

        st = EngineeringSalaryTable.create!(
          engineering_project: project,
          name: name,
          type: type
        )

        last_row = sheet.last_row
        items = {}
        col_count = sheet.row(start_row-1).compact.count
        (start_row..last_row).each do |row_id|
          data = sheet.row(row_id)
          next if data[0].nil?

          if data[0] == '合计'
            data = data.compact
            if col_count == 6
              total = {
                salary_deserve: data[1],
                social_insurance: data[2],
                salary_in_fact: data[3]
              }
            elsif col_count == 8
              total = {
                salary_deserve: data[1],
                social_insurance: data[2],
                salary_in_fact: data[5]
              }
            else
              fail "工资表汇总信息获取失败"
            end
            total.each do |k,v|
              puts "----- Validation failed: unequal #{k} total in #{xlsx_name}-#{sheet_id}" \
                unless total[k].to_f == items.values.map(&k).map(&:to_f).sum
            end

            break
          end

          if col_count == 6
            id, name, salary_deserve, social_insurance, salary_in_fact, _ = \
              sheet.row(row_id).map{|col| String === col ? col.strip : col}
            medical_insurance = nil
          elsif col_count == 8
            id, name, salary_deserve, social_insurance, medical_insurance, _total_insurance, salary_in_fact, _ = \
              sheet.row(row_id).map{|col| String === col ? col.strip : col}
          else
            fail "工资表无法解析：#{path}"
          end

          next if id.nil?

          staff = project.engineering_staffs.where(name: name).first
          fail "未找到员工: #{name} in #{path}" if staff.nil?

          item = st.salary_items.create!(
            engineering_staff: staff,
            salary_deserve: salary_deserve,
            social_insurance: social_insurance,
            medical_insurance: medical_insurance,
            salary_in_fact: salary_in_fact
          )

          items[id.to_i] = item
        end
      end
    end
end

Seed.start(ARGV)
