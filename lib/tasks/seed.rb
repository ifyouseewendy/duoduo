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

    info = customer_dir.entries.detect{|pn| pn.to_s.start_with?('信息汇总') }
    raise "没有信息汇总" if info.nil?
    handling_project_info(file: customer_dir.join(info), customer: customer)

    customer_dir.entries.each do |pn|
      next if pn.to_s.start_with?('.') or pn.to_s.start_with?('信息汇总')
      puts "--- #{pn}"

      customer_dir.join(pn).entries.each do |file|
        next if file.to_s.start_with?('.')
        puts "----- #{file.to_s}"

        if file.to_s.index('代发协议')
        elsif file.to_s.index('工程合同')
        elsif file.to_s.index('工资表')
        elsif file.to_s.index('用工明细')
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
        EngineeringStaff, EngineeringProject, EngineeringCorp, EngineeringCustomer,
        EngineeringSalaryTable,
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

    def handling_project_info(file:, customer:)
      # 处理信息汇总
      sc = get_sub_company_by(name: file.basename.to_s)
      customer.sub_companies << sc

      xlsx_name = file.to_s
      xlsx = Roo::Spreadsheet.open(xlsx_name)
      sheet_id = 0
      sheet = xlsx.sheet(sheet_id)

      last_row = sheet.last_row
      projects = []
      (3..last_row).each do |row_id|
        if row_id == last_row
          data = sheet.row(row_id)
          if data[0] == '合计'
            total = {
              project_amount: data[4],
              admin_amount: data[5],
              total_amount: data[8],
              outcome_amount: data[12]
            }
            total.each do |k,v|
              puts "----- Validation failed: unequal #{k} total: #{xlsx_name}" unless total[k].to_f == projects.map(&k).map(&:to_f).sum
            end

            next
          end
        end

        id, start_date, project_dates, name, project_amount, admin_amount, _project_amount, _admin_amount, total_amount, income_date, outcome_date, outcome_referee, outcome_amount, proof = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        project = customer.engineering_projects.where(name: name).first
        if project.present?
          projects << project
          next
        end

        project_start_date, project_end_date = parse_project_dates(project_dates)
        project = customer.engineering_projects.create!(
          name: name,
          start_date: start_date,
          project_start_date: project_start_date,
          project_end_date: project_end_date,
          project_amount: project_amount,
          admin_amount: admin_amount,
          income_date: income_date,
          outcome_date: outcome_date,
          outcome_referee: outcome_referee,
          outcome_amount: outcome_amount,
          proof: proof
        )

        fail "Validation failed: unequal project total_amount: #{id}" if project.total_amount != total_amount.to_f

        projects << project
      end
    end
end

Seed.start(ARGV)
