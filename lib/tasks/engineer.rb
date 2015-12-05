require_relative 'duoduo_cli'

class Engineer < DuoduoCli
  attr_reader :logger

  class << self
    # Use class instance variable to share betwen import and engineer
    attr_reader :current_path

    def init_current_path(path)
      @current_path = [path]
    end

    def join_current_path
      " | #{File.join(*current_path)}"
    end
  end

  desc "base", ''
  def base
    load_rails
    init_logger

    clean_db

    seed_admin_user
    seed_sub_companies
  end

  desc "batch_start", ''
  option :from, required: true
  def batch_start
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    # load_rails
    base

    logger.info "[#{Time.now}] Import start"

    dir = Pathname(options[:from])
    dir.entries.sort.each do |customer|
      next if skip_files.any?{|f| customer.to_s.start_with?(f)}

      self.class.new.invoke('start', [], from: dir.join(customer) )
    end

    logger.info "[#{Time.now}] Import end"
  end

  desc "start", "Import engineering data"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/engineer.rb start --from=
  LONGDESC
  option :from, required: true
  def start
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails unless defined? Rails

    init_logger
    logger.level = Logger::ERROR
    customer_dir = Pathname(options[:from])
    logger.info "- #{customer_dir.basename}"

    init_current_path customer_dir
    logger.error "--> #{customer_dir.basename}"

    # 客户
    customer = EngineeringCustomer.find_or_create_by!(name: customer_dir.basename.to_s)

    # 信息汇总
    projects = handling_project_info_files(dir: customer_dir, customer: customer)

    # 项目
    customer_dir.entries.sort.each do |pn|
      next if skip_files.any?{|f| pn.to_s.start_with?(f)} \
        or special_files.any?{|f| pn.to_s =~ /#{f}/}

      logger.info "--- #{pn}"
      current_path.push(pn)

      id, _name = pn.to_s.split('、')
      project = projects[id.to_i]

      if project.nil?
        logger.info "----- 特例跳过"
        current_path.pop
        next
      end

      # 用工明细
      handling_project_staff(dir: customer_dir.join(pn), project: project)

      # 合同、协议、工资表
      customer_dir.join(pn).entries.each do |file|
        next if skip_files.any?{|f| file.to_s.start_with?(f)} or file.to_s =~ /用工/ or file.to_s =~ /明细表/
        logger.info "----- #{file.to_s}"

        current_path.push file

        path = customer_dir.join(pn).join(file)

        if file.to_s =~ /合同/
          project.add_contract_file(path: path, role: :normal)
        elsif file.to_s =~ /协议/
          project.add_contract_file(path: path, role: :proxy)
        elsif file.to_s =~ /工资/
          handling_salary_table(path: path, project: project, type: :normal)
        else
          logger.error "xxxxx 无法解析文件: #{join_current_path}"
        end

        current_path.pop
      end

      current_path.pop
    end

    # 提供人员
    handling_staff_dirs(dir: customer_dir, customer: customer)
  end

  private

    def get_sub_company_by(name:)
      if name.index('东方')
        SubCompany.query_name('东方').first
      elsif name.index('人力分')
        SubCompany.query_name('公主岭').first
      elsif name.index('人力')
        SubCompany.where(name: '吉易人力资源').first
      else
        logger.error "xxx 无法解析子公司名称: #{name} #{join_current_path}"
        nil
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
      fail "xxxxx 无法解析工程日期: #{str} #{join_current_path}" if str.split('-').count > 2

      start_date, end_date = str.split('-')

      start_date = revise_date start_date

      if end_date.nil?
        end_date = start_date.end_of_month
      else
        year = start_date.year

        parts = end_date.split('.')

        if parts.count == 3
          # 2013.1.1
        elsif parts.count == 2
          if parts[0].length == 4
            # 2014.1
            parts << '1'
          elsif parts[0].length == 2
            if parts[0].to_i <= 12
              # 12.5 => 2015.12.5
              parts.unshift '2015'
            else
              # 13.5 => 2013.5.1
              parts[0] = "20#{parts[0]}"
              parts << '1'
            end
          end
        elsif parts.count == 1
          parts.unshift year
          parts.push '1'
        else
          fail "xxxxx 无法解析工程结束日期：#{end_date} #{join_current_path}"
        end

        end_date = Date.parse parts.join('.')
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
        logger.error "xxxxx 无法解析工程开始日期：#{date} #{join_current_path}"
        raise e
      end
    end

    # 处理信息汇总
    def handling_project_info(file:, customer:)
      logger.info "--- #{file.basename}"

      sc = get_sub_company_by(name: file.basename.to_s)
      return if sc.nil?

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
          if col_count == 16
            data = data[3..-1]
          elsif col_count == 14
            data = data[1..-1]
          end

          total = {
            project_amount: data[0].to_f.round(2),
            admin_amount: data[1].to_f.round(2),
            total_amount: data[2].to_f.round(2),
          }
          total_i18n = {
            project_amount: '劳务费',
            admin_amount: '管理费',
            total_amount: '费用合计',
            outcome_amount: '回款合计'
          }
          total.each do |k,v|
            logger.error "xxxxx 校验失败: #{total_i18n[k]} #{total[k]} #{join_current_path}" unless total[k] == projects.values.map(&k).map(&:to_f).sum.round(2)
          end

          outcome_amount = data[-1]
          outcome_amount = outcome_amount.to_f.round(2)
          logger.error "xxxxx 校验失败: #{total_i18n[:outcome_amount]} #{outcome_amount} #{join_current_path}" unless outcome_amount == projects.values.map{|pr| pr.outcome_items.map(&:amount).sum }.sum.to_f.round(2)

          break
        end

        if col_count == 16
          id, start_date, project_dates, name, _project_amount, _admin_amount, project_amount, admin_amount, total_amount, income_date, income_amount, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            sheet.row(row_id).map{|col| String === col ? col.strip : col}
        elsif col_count == 14
          id, start_date, project_dates, name, project_amount, admin_amount, total_amount, income_date, income_amount, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            sheet.row(row_id).map{|col| String === col ? col.strip : col}
        else
          logger.error "xxxxx 无法解析信息汇总：错误的列数 #{col_count} #{join_current_path}"
          break
        end

        begin
          project_start_date, project_end_date = parse_project_dates(project_dates.to_s)
        rescue => e
          logger.error e.message
          next
        end

        project = customer.engineering_projects.create!(
          name: "#{id.to_i}、#{name}",
          start_date: start_date,
          project_start_date: project_start_date,
          project_end_date: project_end_date,
          project_amount: project_amount,
          admin_amount: admin_amount,
          proof: proof,
          remark: remark
        )

        income_date, income_amount, outcome_amount, outcome_date, outcome_referee = \
          split_by_comma(income_date),
          split_by_comma(income_amount),
          split_by_comma(outcome_amount),
          split_by_comma(outcome_date),
          split_by_comma(outcome_referee)

        unless income_date.blank?
          income_date.zip(income_amount).each do |date, amount|
            project.income_items.create!(date: date, amount: amount)
          end
        end

        unless outcome_referee.blank?
          outcome_referee.each_with_index do |referee, idx|
            date = outcome_date[idx]
            amount = outcome_amount[idx]
            project.outcome_items.create!(date: date, amount: amount, persons: referee.to_s.split(' ').map(&:strip))
          end
        end

        logger.error "xxx 校验失败：劳务费加管理费不等于费用合计，id: #{id.to_i} #{join_current_path}" if project.total_amount.to_f.round(2) != total_amount.to_f.round(2)

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
          name: name.delete(' '),
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

      xlsx.sheets.each_with_index do |sheet_name, sheet_id|
        logger.info "------- Sheet #{sheet_id+1}"
        sheet = xlsx.sheet(sheet_id)

        parts = sheet_name.split('.').map(&:strip)
        parts << '1' if parts.count == 2

        if parts.count != 3
          logger.error "xxxxxxx 无法解析工资表表单名：#{sheet_name} #{join_current_path}"
          next
        end

        begin
          date = Date.parse parts.join('.')
        rescue => _
          logger.error "xxxxxxx 无法解析工资表表单名：#{sheet_name} #{join_current_path}"
          next
        end
        name = "#{date.year}年#{date.month}月"

        logger.error "xxxxxxx 工资表日期不在工程日期内: #{sheet_name} #{join_current_path}" \
          unless date >= project.range[0].beginning_of_month && date <= project.range[1].end_of_month

        if sheet.row(3).compact.count == 1
          start_row = 5
        elsif sheet.row(2).compact.count == 1
          start_row = 4
        elsif sheet.row(1).compact.count == 1
          start_row = 3
        else
          logger.error "xxxxxxx 无法解析工资表：#{sheet_name} #{join_current_path}"
          next
        end

        col_count = sheet.row(start_row-1).compact.count
        if col_count == 10
          type = 'EngineeringNormalWithTaxSalaryTable'
        end

        st = EngineeringSalaryTable.create!(
          engineering_project: project,
          name: name,
          type: type
        )

        last_row = sheet.last_row
        items = {}
        (start_row..last_row).each do |row_id|
          data = sheet.row(row_id)
          next if data[0].nil?

          if data[0] == '合计' or data[0] == '小计'
            data = data.compact
            if col_count == 6 or col_count == 5
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
            elsif col_count == 10 # 带个税
              total = {
                salary_deserve: data[1],
                social_insurance: data[2],
                salary_in_fact: data[-1]
              }
            elsif col_count >= 15
              # TODO 待处理工程大表导入
            else
              logger.error "xxxxxxx 无法解析工资表，错误的列数 #{col_count}： #{join_current_path}"
              next
            end

            total_i18n = {
              salary_deserve: '应发工资',
              social_insurance: '税金',
              salary_in_fact: '实发工资'
            }

            total.each do |k,v|
              logger.error "xxxxxxx 校验失败：#{total_i18n[k]} #{v.to_f} #{join_current_path}" \
                unless total[k].to_f.round(2) == items.values.map(&k).map(&:to_f).sum.round(2)
            end

            break
          end

          if col_count == 6 or col_count == 5
            id, name, salary_deserve, social_insurance, salary_in_fact, _ = \
              sheet.row(row_id).map{|col| String === col ? col.strip : col}
            medical_insurance = nil
          elsif col_count == 8
            id, name, salary_deserve, social_insurance, medical_insurance, _total_insurance, salary_in_fact, _ = \
              sheet.row(row_id).map{|col| String === col ? col.strip : col}
          elsif col_count == 10
            id, name, salary_deserve, social_insurance, medical_insurance, _total_insurance, _total_amount, tax, salary_in_fact, _ = \
              sheet.row(row_id).map{|col| String === col ? col.strip : col}
          elsif col_count >= 15
            # TODO 待处理工程大表导入
            logger.info "xxxxxxx 待处理大表"
            break
          else
            logger.error "xxxxxxx 无法解析工资表，错误的列数 #{col_count}: #{sheet_name} #{join_current_path}"
            next
          end

          next if id.nil?

          name = name.delete(' ')
          staff = project.engineering_staffs.where(name: name).first
          if staff.nil?
            logger.error "xxxxxxx 未找到员工: #{name} #{join_current_path}"
            next
          end

          if col_count == 10
            item = st.salary_items.create!(
              engineering_staff: staff,
              salary_deserve: salary_deserve,
              social_insurance: social_insurance,
              medical_insurance: medical_insurance,
              salary_in_fact: salary_in_fact,
              tax: tax.to_f
            )
          else
            item = st.salary_items.create!(
              engineering_staff: staff,
              salary_deserve: salary_deserve,
              social_insurance: social_insurance,
              medical_insurance: medical_insurance,
              salary_in_fact: salary_in_fact
            )
          end

          items[id.to_i] = item
        end
      end
    end

    def split_by_comma(string)
      string.to_s.split(',').map(&:strip)
    end

    def handling_project_staff_list(file:, customer:)
      logger.info "----- #{file.basename}"

      xlsx_name = file.to_s
      xlsx = Roo::Spreadsheet.open(xlsx_name)
      sheet_id = 0
      sheet = xlsx.sheet(sheet_id)

      last_row = sheet.last_row
      (3..last_row).each do |row_id|
        _id, name, gender, identity_card, remark = \
          sheet.row(row_id).map{|col| String === col ? col.strip : col}

        next if _id.nil?

        gender_map = {'男' => :male, '女' => :female}

        staff = customer.engineering_staffs.where(name: name).first
        next if staff.present? && staff.identity_card.present? && remark.blank?

        staff ||= EngineeringStaff.create!(
          engineering_customer: customer,
          name: name,
          gender: gender_map[gender],
          identity_card: identity_card
        )
        staff.identity_card = identity_card if staff.identity_card.blank?
        staff.remark = remark
        staff.save!
      end
    end

    def handling_project_info_files(dir:, customer:)
      infos = dir.entries.select{|pn| pn.to_s =~ /信息汇总/ }
      if infos.blank?
        logger.error "xxx 没有信息汇总 #{join_current_path}"
        return
      end

      projects = {}
      infos.each do |info|
        current_path.push info

        stats = handling_project_info(file: dir.join(info), customer: customer)
        projects.merge!(stats)

        current_path.pop
      end

      projects
    end

    def handling_project_staff(dir:, project:)
      staff_file = dir.entries.detect{|file| file.to_s =~ /用工/ or file.to_s =~ /明细表/ }
      return if staff_file.nil?

      logger.info "----- #{staff_file.to_s}"

      current_path.push(staff_file)
      handling_staff(path: dir.join(staff_file), project: project)
      current_path.pop
    end

    def handling_staff_dirs(dir:, customer:)
      staff_dir = dir.entries.detect{|dir| dir.to_s =~ /提供人员/ && !dir.to_s.start_with?('__')}
      return unless staff_dir.present?

      logger.info "--- #{staff_dir}"
      dir.join(staff_dir).entries.each do |list|
        next if list.to_s.start_with?('.')

        handling_project_staff_list(file: dir.join(staff_dir).join(list), customer: customer)
      end
    end

    def special_files
      @_special_files ||= %w(信息汇总 提供人员)
    end

    def skip_files
      @_skip_files ||= %w(. __ ~)
    end

    def init_logger
      @logger = ActiveSupport::Logger.new('log/import.log')
    end

    def init_current_path(path)
      self.class.init_current_path(path)
    end

    def join_current_path
      self.class.join_current_path
    end

    def current_path
      self.class.current_path
    end
end

Engineer.start(ARGV)