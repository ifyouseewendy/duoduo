require_relative 'duoduo_cli'

class Engineer < DuoduoCli
  attr_reader :logger, :customer_dir, :customer, :project_info, :project_info_xlsx, :projects

  $PERHAPS = Set.new

  desc "batch_start", ''
  option :from, required: true
  option :skip_clean, type: :boolean
  option :only_staff, type: :boolean
  option :only_salary, type: :boolean
  option :only_project, type: :boolean
  option :only_contract, type: :boolean
  def batch_start
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails
    clean_db(:engineer, :engineer_corp) unless options[:skip_clean]

    clean_logger
    init_logger

    logger.info "[#{Time.now}] Import start"

    dir = Pathname(options[:from])

    # 单位部分医保、社保金额
    seed_engineer_insurance

    # 大协议
    contract_path = dir.entries.detect{|en| en.basename.to_s == '__大协议'}
    if contract_path.present?
      self.class.new.invoke('add_big_contract', [], from: dir.join(contract_path))
    end

    # 提供人员
    self.class.new.invoke('validate_staff', [], from: options[:from])

    # 项目文件夹
    entries = dir.entries.reject{|en| skip_file?(en)}.sort_by{|en| en.basename.to_s.split('、')[0].to_i }
    entries.each do |entry|
      self.class.new.invoke('start', [],
        from: dir.join(entry),
        batch: true,
        only_staff: options[:only_staff],
        only_salary: options[:only_salary],
        only_project: options[:only_project],
        only_contract: options[:only_contract],
       )
    end

    logger.info "[#{Time.now}] Import end"

    fatal_result = Rails.root.join("log").join("添加到各客户提供人员不可用.csv")
    logger.set_fatal_path fatal_result
    $PERHAPS.each{|perhap| logger.fatal perhap}

    # Extract nest_index from name
    fix_all_project_nest_index_and_name
  end

  desc "start", "Import engineering data"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/engineer.rb start --from=
  LONGDESC
  option :from, required: true
  option :batch
  option :only_staff, type: :boolean
  option :only_salary, type: :boolean
  option :only_project, type: :boolean
  option :only_contract, type: :boolean
  def start
    unless options[:batch]
      load_rails
      clean_db(:engineer)
      clean_logger
    end

    init_logger
    logger.set_info_path(STDOUT)

    warn_result  = Rails.root.join("log").join("用工明细员工校验结果.csv")
    logger.set_warn_path warn_result

    logger.info "[#{Time.now}] Import start"

    set_customer_dir load_from(options[:from])
    logger.info "- #{customer_dir.basename}"

    # 信息汇总
    set_projects process_project_infos
    return if options[:only_project]

    # 提供人员 Use validate_staff instead
    # process_provide_staff_dir

    # 项目
    iterate_projects(options)

    logger.info warn_result.to_s
  end

  desc 'validate_staff', ''
  option :from, required: true
  def validate_staff
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails
    clean_db(:engineer)

    clean_logger
    init_logger
    logger.set_info_path(STDOUT)

    logger.info "[#{Time.now}] Import start"

    dir = Pathname(options[:from])
    dir.entries.sort.each do |entry|
      next if skip_file?(entry)

      set_customer_dir load_from(dir.join(entry))
      logger.info "- #{customer_dir.basename}"

      process_provide_staff_dir
    end
    prcoess_duplicate_between_customers

    logger.info "[#{Time.now}] Import end"
  end

  desc 'add_big_contract', ''
  option :from, required: true
  def add_big_contract
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails
    clean_db(:engineer_corp)

    init_logger
    logger.set_info_path(STDOUT)

    logger.info "[#{Time.now}] Import start"

    dir = Pathname(options[:from])
    entries = dir.entries.sort_by{|en| en.to_s.split[0]}
    entries.each do |entry|
      next if skip_file?(entry)

      entry = dir.join(entry)
      parts = entry.basename.to_s.split('.')[0..-2].join('.').split.map(&:strip)

      flag, company_name, corp_name, dates = parts
      sub_company = find_sub_company_by(name: company_name)
      contract_start_date, contract_end_date = dates.split('-').map{|d| Date.parse(d)}

      ec = EngineeringCorp.find_or_create_by!(name: corp_name)
      ec.big_contracts.create!(
        sub_company: sub_company,
        start_date: contract_start_date,
        end_date: contract_end_date,
        contract: File.open(entry)
      )
    end

    EngineeringCorp.all.each do |ec|
      contract = ec.big_contracts.order(end_date: :desc).first
      next if contract.nil?
      contract.update_attribute(:enable, true)
    end

    logger.info "[#{Time.now}] Import end"
  end


  desc 'seed_engineer_insurance', ''
  def seed_engineer_insurance
    load_rails

    seed_engineering_company_social_insurance_amounts
    seed_engineering_company_medical_insurance_amounts
  end

  private

    def find_sub_company_by(name:)
      name = name.to_s
      if name.index('东方')
        SubCompany.query_name('东方').first
      elsif name.index('人力分')
        SubCompany.query_name('公主岭').first
      elsif name.index('人力')
        SubCompany.where(name: '吉易人力资源').first
      elsif name.index('百奕')
        SubCompany.query_name('百奕').first
      else
        logger.error "#{better_path(project_info)} ; 项目汇总 ; 无法解析子公司名称: #{name}"
        nil
      end
    end

    def parse_project_dates(str)
      fail "项目汇总 ; 无法解析工程日期: #{str} ; #{project_info}" if str.split('-').count > 2

      start_date, end_date = str.gsub("。", '.').split('-').map(&:strip)

      start_parts = start_date.split('.')
      start_date = revise_project_date start_date

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
          if start_parts.count == 2
            parts.unshift year
            parts.push '1'
          elsif start_parts.count == 3
            month = start_date.month
            parts.unshift month
            parts.unshift year
          end
        else
          fail "项目汇总 ; 无法解析工程结束日期：#{end_date} #{project_info}"
        end

        end_date = Date.parse parts.map(&:to_s).join('.')
        end_date = end_date.end_of_month if end_date.day == 1
      end

      [start_date, end_date]
    end

    # 2015.4
    def revise_project_date(date)
      parts = date.split('.')
      parts << '1' if parts.count == 2

      begin
        Date.parse parts.join('.')
      rescue => e
        logger.error "#{better_path project_info} ; 项目汇总 ; 无法解析工程开始日期：#{date}"
        raise e
      end
    end

    def split_by_comma(string)
      string.to_s.split(/,|，/).map(&:strip)
    end

    def process_provide_staff_file(file)
      logger.info "----- #{file.basename}"

      enable = parse_staff_enable(file)

      xlsx = Roo::Spreadsheet.open(file.to_s)
      sheet = xlsx.sheet(0).to_a

      return if sheet[2..-1].blank?

      sheet[2..-1].each do |data|
        _id, name, gender, identity_card, remark = \
          data.map{|col| String === col ? col.strip : col}

        next if _id.nil?

        gender_map = {'男' => 0, '女' => 1}

        begin
          staff = customer.staffs.where(identity_card: identity_card).first
          next if staff.present? && staff.name == name.try(:strip)

          # staff = EngineeringStaff.where(identity_card: identity_card).first

          # if staff.present?
          #   if staff.engineering_customer.id != customer.id
          #     logger.error "#{better_path file} ; 提供人员 ; 员工信息校验 ; 员工（#{staff.name} - #{identity_card}）属于客户（#{staff.engineering_customer.name}），又出现在客户（#{customer.name}）的提供人员中"
          #   end
          # else

          staff = EngineeringStaff.create!(
            customer: customer,
            name: name.try(:delete, ' '),
            gender: gender_map[gender],
            identity_card: identity_card,
            enable: enable,
            remark: remark
          )

          # end

        rescue => e
          logger.error "#{better_path file} ; 提供人员 ; 提供人员 ; #{name} #{e.message} ; #{e.backtrace[0]}"
        end
      end
    end

    def process_provide_staff_dir
      staff_dir = customer_dir.entries.detect{|dir| dir.to_s =~ /提供人员/ && !dir.to_s.start_with?('__')}
      return if staff_dir.blank?
      logger.info "--- #{staff_dir}"

      staff_dir = customer_dir.join(staff_dir)
      staff_dir.entries.each do |list|
        next if list.to_s.start_with?('.')

        process_provide_staff_file(staff_dir.join(list))
      end
    end

    def special_files
      @_special_files ||= %w(信息汇总 提供人员)
    end

    def skip_files
      @_skip_files ||= %w(. __ ~)
    end

    def init_current_path(path)
      self.class.init_current_path(path)
    end

    def current_path
      self.class.current_path
    end

    def set_customer_dir(path)
      @customer_dir = path
      set_customer
    end

    def set_customer
      filename = customer_dir.basename.to_s
      nest_index, name = filename.split('、')
      name ||= nest_index # 公司自供人员
      @customer = EngineeringCustomer.find_or_create_by!(name: name, nest_index: nest_index.to_i)
    end

    def process_project_infos
      files = get_project_info_files

      # logger.error "#{better_path customer_dir} ; 项目汇总 ; 没有信息汇总" and return if files.blank?
      return {} if files.blank?

      files.reduce({}) do |ha, file|
        set_project_info(file)
        stats = process_project_info || {}
        ha.merge!(stats)
      end
    end

    def set_project_info(file)
      @project_info = file
    end

    def get_project_info_files
      customer_dir.entries
        .select{|pn| pn.to_s =~ /信息汇总/ }
        .map{|pn| customer_dir.join(pn)}
    end

    def process_project_info
      logger.info "--- #{project_info.basename}"

      sc = find_sub_company_by(name: project_info.basename.to_s)
      return if sc.nil?

      set_project_info_xlsx
      process_project_info_xlsx(sc)
    end

    def add_project_to_sub_company(project)
      customer.projects << project
    end

    def set_project_info_xlsx
      @project_info_xlsx = Roo::Spreadsheet.open(project_info.to_s)
    end

    def process_project_info_xlsx(sub_company)
      sheet = project_info_xlsx.sheet(0).to_a

      column_count = sheet[1].compact.count

      projects = {}
      sheet[2..-1].each do |data|
        next if data[0].nil?

        if data[0] == '合计'
          parse_project_info_summary(projects, data, column_count)
          break
        end

        if column_count == 16
          id, start_date, project_dates, name, _project_amount, _admin_amount, project_amount, admin_amount, total_amount, income_date, income_amount, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            data.map{|col| String === col ? col.strip : col}
        elsif column_count == 14
          id, start_date, project_dates, name, project_amount, admin_amount, total_amount, income_date, income_amount, outcome_date, outcome_referee, outcome_amount, proof, remark = \
            data.map{|col| String === col ? col.strip : col}
        else
          logger.error "#{better_path project_info} ; 项目汇总 ; 无法解析信息汇总：错误的列数 #{column_count}"
          break
        end

        begin
          if project_dates.blank?
            project_start_date, project_end_date = nil, nil
          else
            project_start_date, project_end_date = parse_project_dates(project_dates.to_s)
          end
        rescue => _
          logger.error "#{better_path project_info} ; 项目汇总 ; 无法解析工程起止日期：#{project_dates}"
          next
        end

        id = id.to_i if Float === id
        begin
          project = customer.projects.create!(
            name: "#{id}、#{name}",
            start_date: start_date,
            project_start_date: project_start_date,
            project_end_date: project_end_date,
            project_amount: project_amount,
            admin_amount: admin_amount,
            proof: proof,
            remark: remark,
            sub_company: sub_company
          )
        rescue => e
          logger.error "#{better_path project_info} ; 项目汇总 ; 创建项目失败: #{e.message}"
        end

        income_date, income_amount, outcome_amount, outcome_date, outcome_referee = \
          split_by_comma(income_date),
          split_by_comma(income_amount),
          split_by_comma(outcome_amount),
          split_by_comma(outcome_date),
          split_by_comma(outcome_referee)

        unless income_date.blank?
          income_date.zip(income_amount).each do |date, amount|
            begin
              project.income_items.create!(date: date, amount: amount)
            rescue => e
              logger.error "#{better_path project_info} ; 项目汇总 ; 创建来款记录失败: #{e.message}"
            end
          end
        end

        unless outcome_referee.blank?
          outcome_referee.each_with_index do |referee, idx|
            begin
              date = outcome_date[idx]
              amount = outcome_amount[idx]
              project.outcome_items.create!(date: date, amount: amount, persons: referee.to_s.split(' ').map(&:strip))
            rescue => e
              logger.error "#{better_path project_info} ; 项目汇总 ; 创建回款记录失败: #{e.message}"
            end
          end
        end

        logger.error "#{better_path project_info} ; 项目汇总 ; 校验失败：劳务费加管理费不等于费用合计，id: #{id}"\
          unless equal_value?(project.total_amount, total_amount)

        projects[id.to_s] = project
      end

      projects
    end

    def parse_project_info_summary(projects, data, column_count)
      data = data.compact
      if column_count == 16
        data = data[3..-1]
      elsif column_count == 14
        data = data[1..-1]
      end

      total = {
        project_amount: data[0],
        admin_amount: data[1],
        total_amount: data[2],
        outcome_amount: data[-1]
      }
      total_i18n = {
        project_amount: '劳务费',
        admin_amount: '管理费',
        total_amount: '费用合计',
        outcome_amount: '回款合计'
      }
      total.each do |k,v|
        value_in_file = v.to_f.round(2)
        if k == :outcome_amount
          value_calc = projects.values.map{|pr| pr.outcome_items.map(&:amount).map(&:to_f).sum }.sum.to_f.round(2)
          logger.error "#{better_path project_info} ; 项目汇总 ; 校验失败: #{total_i18n[k]} ; 文件中合计 #{value_in_file} - 累加合计 #{value_calc}" \
            unless equal_value?(value_in_file, value_calc)
        else
          value_calc = projects.values.map(&k).map(&:to_f).sum
          logger.error "#{better_path project_info} ; 项目汇总 ; 校验失败: #{total_i18n[k]} ; 文件中合计 #{value_in_file} - 累加合计 #{value_calc}" \
            unless equal_value?(value_in_file, value_calc)
        end
      end
    end

    def equal_value?(a,b)
      a.to_f.round(2) == b.to_f.round(2)
    end

    def skip_file?(pn)
      skip_files.any?{|f| pn.to_s.start_with?(f)}
    end
    def special_file?(pn)
      special_files.any?{|f| pn.to_s =~ /#{f}/}
    end

    def set_projects(ary)
      @projects = ary
    end

    def iterate_projects(option)
      entries = customer_dir.entries.reject{|en| skip_file?(en) or en.to_s.index('提供人员')}.sort_by{|en| en.basename.to_s.split(/[、|.]/)[0].to_i }
      entries.each do |pn|
        next if skip_file?(pn) or special_file?(pn)

        logger.info "--- #{pn}"

        id, _name = pn.to_s.split(/[.|、]/)
        project = projects[id.strip]

        dir = customer_dir.join(pn)

        logger.error "#{better_path dir} ; 扫描项目文件夹 ; 未在项目汇总中找到该项目" and next if project.blank?

        if option[:only_staff]
          staff_files    = find_in_project_dir(dir: dir, type: :staff)
          process_staff_files(staff_files, project)
          next
        end

        if option[:only_salary]
          salary_files   = find_in_project_dir(dir: dir, type: :salary)
          process_salary_files(salary_files, project)
          next
        end

        if option[:only_contract]
          contract_files = find_in_project_dir(dir: dir, type: :contract)
          process_contract_files(contract_files, project)

          proxy_files    = find_in_project_dir(dir: dir, type: :proxy)
          process_proxy_files(proxy_files, project)

          next
        end

        staff_files    = find_in_project_dir(dir: dir, type: :staff)
        process_staff_files(staff_files, project)

        contract_files = find_in_project_dir(dir: dir, type: :contract)
        process_contract_files(contract_files, project)

        proxy_files    = find_in_project_dir(dir: dir, type: :proxy)
        process_proxy_files(proxy_files, project)

        salary_files   = find_in_project_dir(dir: dir, type: :salary)
        process_salary_files(salary_files, project)
      end
    end

    def find_in_project_dir(dir:, type:)
      entries = dir.entries.reject{|en| skip_file?(en)}
      files = \
        case type.to_sym
        when :staff
          entries.select{|file| file.to_s =~ /用工/ or file.to_s =~ /明细表/ }
        when :contract
          entries.select{|file| file.to_s =~ /合同/}
        when :proxy
          entries.select{|file| file.to_s =~ /协议/}
        when :salary
          entries.select{|file| file.to_s =~ /工资/}
        else
          logger.error "#{better_path dir} ; 项目文件夹 ; 无法解析项目内文件"
          return
        end
      files.map{|f| dir.join(f)}
    end

    def process_staff_files(files, project)
      files.each do |file|
        logger.info "----- #{file.basename}"
        process_staff_file(file, project)
      end
    end

    def process_staff_file(file, project)
      xlsx = Roo::Spreadsheet.open(file.to_s)
      sheet = xlsx.sheet(0).to_a

      sheet[2..-1].each do |data|
        _id, name, gender, identity_card = data.map{|col| String === col ? col.strip : col}
        next if _id.nil?

        name = name.try(:delete, ' ')
        next if name == '姓名'

        identity_card = identity_card.try(:delete, " ") # This is a ghost space from xls, which bytes is [194, 160]

        begin
          staff = EngineeringStaff.where(identity_card: identity_card).first

          if staff.present?
            # logger.error "#{better_path file} ; 用工明细 ; 员工信息校验 ; 员工（#{staff2.name} - #{identity_card}）属于客户（#{staff2.engineering_customer.name}）"

            if staff.name != name
              logger.warn "#{better_path file} ; 用工明细 ; 员工信息校验 ; 号工（#{name} - #{identity_card}）在客户（#{staff.customer.name}）中存为（#{staff.name}）"
              staff.update_attribute(:alias_name, name)
            end
            staff.projects << project
          else
            perhaps = []
            perhaps = EngineeringStaff.where(name: name).to_a

            if perhaps.blank?
              # 附加到该客户的提供人员（不可用）中

              $PERHAPS << [project.customer.name, name, "'#{identity_card}"].join(';')

              # gender_map = {'男' => 0, '女' => 1}
              # staff = EngineeringStaff.create!(
              #   engineering_customer: project.engineering_customer,
              #   name: name,
              #   gender: gender_map[gender],
              #   identity_card: identity_card,
              #   enable: false
              # )
              # staff.engineering_projects << project
            else
              if perhaps.count == 1 && (perhaps[0].customer.id == project.customer.id)
                staff = perhaps[0]
                staff.projects << project
              else
                perhaps_output = perhaps.map{|st| [st.name, st.identity_card, st.customer.name].join(';')}.join(';')
                logger.warn "#{better_path file} ; 用工明细 ; 员工信息校验 ; 号工（#{name} - #{identity_card}）未在任何客户中找到 ; #{perhaps_output}"
              end
            end
          end

          # staff.engineering_projects << project
        rescue => e
          logger.warn "#{better_path file} ; 用工明细 ; 用工明细 ; #{name} #{e.message} ; #{e.backtrace[0]}"
        end
      end
    end

    def process_contract_files(files, project)
      files.each do |file|
        logger.info "----- #{file.basename}"
        set_project_date_range(project: project, path: file)
        set_engineering_corp(project: project, path: file)
        project.add_contract_file(path: file, role: :normal)
      end
    end

    def set_project_date_range(project:, path:)
      DocGenerator::TempPath.execute do |temp_path|
        FileUtils.cp path, temp_path
        file = temp_path.join( Pathname.new(path).basename )

        DocRipper::rip(file.to_s) # Generate a file named #{file.basename}.txt
        txt_file = file.basename.to_s.split('.')[0,1].push('txt').join('.')

        data = File.read txt_file
        line = data.delete(' ').split.detect{|str| str =~ /\d{4}年\d+月\d+日/  }

        if line.blank?
          logger.error "#{better_path path} ; 合同文件 ; 无法解析合同起止日期"
        else
          words = line.delete('.').match(/(\d{4}年\d+月\d+日).*(\d{4}年\d+月\d+日)/)
          parts = words[1,2]

          start_date = convert_chinese_date(parts[0])
          logger.error "#{better_path path} ; 合同文件 ; 无法通过合同判断起始日期：#{parts[0]}" if start_date.blank?
          end_date = convert_chinese_date(parts[1])
          logger.error "#{better_path path} ; 合同文件 ; 无法通过合同判断终止日期：#{parts[1]}" if end_date.blank?

          if project.range != [start_date, end_date]
            logger.info "----- 解析合同文件，并更新项目起止日期。合同：#{project.range.map(&:to_s).join(' ~ ')}，汇总：#{[start_date, end_date].map(&:to_s).join(' ~ ')}"
          end

          if start_date.present?
            project.project_start_date = start_date
          end
          if end_date.present?
            project.project_end_date = end_date
          end

          project.save!
        end
      end
    end

    def set_engineering_corp(project:, path:)
      DocGenerator::TempPath.execute do |temp_path|
        FileUtils.cp path, temp_path
        file = temp_path.join( Pathname.new(path).basename )

        DocRipper::rip(file.to_s) # Generate a file named #{file.basename}.txt
        txt_file = file.basename.to_s.split('.')[0,1].push('txt').join('.')

        data = File.read txt_file
        line = data.delete(' ').split.detect{|str| str.start_with?('乙方') }

        if line.blank?
          logger.error "#{better_path path} ; 合同文件 ; 无法解析到乙方名称"
        else
          corp_name = line.delete(" ").split(/[:|：]/)[-1]
          ec = EngineeringCorp.where(name: corp_name).first

          if ec.blank?
            ll = data.delete(' ').split.detect{|str| str.start_with?('甲方')}
            logger.error "#{better_path path} ; 合同文件 ; 未找到乙方大协议：#{corp_name} ; #{ll}"
          else
            ec.projects << project
          end
        end
      end
    end

    def convert_chinese_date(date)
      words = date.split(/[年|月|日]/) rescue nil
      return nil if words.blank?
      return nil unless Date.valid_date?(*words.map(&:to_i))

      Date.parse words.join('.')
    end

    def process_proxy_files(files, project)
      return if files.blank?

      oi = project.outcome_items.first
      if oi.blank?
        logger.error "#{better_path files.first} ; 协议文件 ; 没有回款记录，无法记录协议文件 ; #{project.display_name}"
        return
      end

      files.each do |file|
        logger.info "----- #{file.basename}"
        oi.add_contract_file(path: file, role: :proxy)
      end
    end

    def process_salary_files(files, project)
      files.each do |file|
        logger.info "----- #{file.basename}"
        process_salary_file(path: file, project: project, type: :normal)
      end
    end

    def process_salary_file(path:, project:, type:)
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

      ranges = project.split_range xlsx.sheets.reject{|name| name == 'SWDXMTKP' }.count

      custom_range = xlsx.sheets.all?{|name| name.start_with?('!') or name.start_with?("！") }
      ranges = xlsx.sheets.map{|name| name.strip.delete('!！补')}.map{|date| Date.parse(date+'.1')}.map{|date| [date, date.end_of_month]} \
        if custom_range

      xlsx.sheets.each_with_index do |sheet_name, sheet_id|
        next if sheet_name == 'SWDXMTKP' # Werid MS addtional sheet

        logger.info "------- Sheet-#{sheet_id+1}: #{sheet_name}"
        sheet = xlsx.sheet(sheet_id)

        if sheet.row(3).compact.count == 1
          start_row = 5
        elsif sheet.row(2).compact.count == 1
          start_row = 4
        elsif sheet.row(1).compact.count == 1
          start_row = 3
        else
          logger.error "#{better_path path} ; 工资表 ; 无法解析工资表：#{sheet_name}"
          next
        end

        col_count = sheet.row(start_row-1).compact.count
        if col_count == 10
          type = 'EngineeringNormalWithTaxSalaryTable'
        end

        start_date, end_date = ranges[sheet_id]

        begin
          name = [start_date, end_date].join(' ~ ')
          name << ' 补' if sheet_name.index('补')

          st = EngineeringSalaryTable.create!(
            project: project,
            name: name,
            start_date: start_date,
            end_date: end_date,
            type: type
          )
        rescue => e
          logger.error "#{better_path path} ; 工资表 ; #{sheet_name}: #{e.message}"
          next
        end


        last_row = sheet.last_row
        items = {}
        skip_total_check = false
        (start_row..last_row).each do |row_id|
          data = sheet.row(row_id)
          next if data[0].nil?

          if data[0] == '合计' or data[0] == '小计'
            break if skip_total_check

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
              logger.error "#{better_path path} ; 工资表 ; 无法解析工资表，错误的列数 #{col_count}"
              break
            end

            total_i18n = {
              salary_deserve: '应发工资',
              social_insurance: '税金',
              salary_in_fact: '实发工资'
            }

            total.each do |k,v|
              value_in_file = v.to_f.round(2)
              value_calc = items.values.compact.map(&k).map(&:to_f).sum.to_f.round(2)
              logger.error "#{better_path path} ; 工资表 ; 校验失败：#{total_i18n[k]} ; 文件中合计 #{value_in_file} - 累加合计 #{value_calc}" \
                unless equal_value?(value_in_file, value_calc)
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
            remark = nil

            if customer.name.split('、')[0].to_i == 76 # Special
              id, name, salary_deserve, social_insurance, medical_insurance, _total_insurance, salary_in_fact, admin_fee, _total_amount, _ = \
                sheet.row(row_id).map{|col| String === col ? col.strip : col}
              remark = "管理费：#{admin_fee}"
              tax = 0
              skip_total_check = true
            end
          elsif col_count >= 15
            # TODO 待处理工程大表导入
            logger.error "#{better_path path} ; 工资表 ; 待处理大表"
            break
          else
            logger.error "#{better_path path} ; 工资表 ; 无法解析工资表，错误的列数 #{col_count}: #{sheet_name}"
            break
          end

          next if id.nil?

          name = name.try(:delete, ' ')
          staff = project.staffs.where(name: name).first

          # Check alias name
          staff = project.staffs.where(alias_name: name).first if staff.nil?

          # Check customer's provide list
          if staff.nil?
            staff = project.customer.staffs.where(name: name).first
            staff.projects << project if staff.present?
          end

          if staff.nil?
            logger.error "#{better_path path} ; 工资表 ; 员工信息校验 ; 未找到员工: #{name} ; 请加入到客户提供人员（不可用中）"
            skip_total_check = true
            next
          end

          begin
            if col_count == 10
              item = st.salary_items.create!(
                staff: staff,
                salary_deserve: salary_deserve,
                social_insurance: social_insurance,
                medical_insurance: medical_insurance,
                salary_in_fact: salary_in_fact,
                tax: tax.to_f,
                remark: remark
              )
            else
              item = st.salary_items.create!(
                staff: staff,
                salary_deserve: salary_deserve,
                social_insurance: social_insurance,
                medical_insurance: medical_insurance,
                salary_in_fact: salary_in_fact
              )
            end
          rescue => e
            logger.error "#{better_path path} ; 工资表 ; 创建工资条: #{e.message}"
          end

          items[id.to_i] = item
        end

        st.validate_amount
      end
    end

    def better_path(file)
      [customer.name, file.to_s[(customer_dir.to_s.length+1)..-1 ]].join('/')
    end

    def prcoess_duplicate_between_customers
      uniq_ids = EngineeringStaff.pluck(:identity_card).uniq
      duplicated_ids = uniq_ids.reduce([]) do |ar, id|
        if EngineeringStaff.where(identity_card: id).count > 1
          ar << id
        else
          ar
        end
      end

      filepath = Rails.root.join("tmp").join("import_result").join("客户间提供人员校验结果_#{Time.stamp}.xlsx")

      Axlsx::Package.new do |pkg|
        pkg.workbook.add_worksheet(name: '客户间重复员工') do |sheet|
          duplicated_ids.each do |id|
            next if id.blank?

            sheet.add_row ["'#{id}"]

            flag = EngineeringStaff.where(identity_card: id).pluck(:name).uniq.count > 1
            EngineeringStaff.where(identity_card: id).each do |es|
              stats = [nil, es.customer.name]
              stats << es.name if flag
              sheet.add_row stats
            end
            sheet.add_row [nil, nil, '员工姓名不一致'] if flag
          end
        end

        pkg.workbook.add_worksheet(name: '未找到身份证') do |sheet|
          EngineeringStaff.where(identity_card: nil).each do |es|
            sheet.add_row [es.name, es.customer.name]
          end
        end

        pkg.serialize(filepath.to_s)
      end

      puts "--> Generate: #{filepath}"
    end

    def parse_staff_enable(path)
      path.basename.to_s.index('不可') ? false : true
    end

    def fix_project_nest_index_and_name(pr)
      idx, name = pr.name.split(/[、|.]/)
      if name.nil?
        # puts [pr.customer.nest_index, pr.customer.name, pr.name].join(' - ')
        return
      end

      idx = idx.sub('-','.') # 40-1
      if idx.to_i == idx.to_f # 40
        pr.nest_index = idx.to_i
      else # 40.1
        pr.nest_index = idx.to_f.round(1)
      end
      pr.name = name
      pr.save!
    end

    def fix_all_project_nest_index_and_name
      EngineeringProject.all.each do |pr|
        fix_project_nest_index_and_name(pr)
      end
    end

    def seed_engineering_company_social_insurance_amounts
      puts "==> Preparing EngineeringCompanySocialInsuranceAmount"
      ::EngineeringCompanySocialInsuranceAmount.destroy_all

      dates = %w(2000-01-01 2014-01-01 2014-07-01 2015-01-01)
      amounts = [0, 200, 300, 407]

      dates.each_with_index do |start_date, idx|
        next_date = dates[idx+1]
        end_date = next_date.to_date.yesterday rescue nil
        ::EngineeringCompanySocialInsuranceAmount.create!(
          start_date: Date.parse(start_date),
          end_date: end_date,
          amount: amounts[idx]
        )
      end
    end

    def seed_engineering_company_medical_insurance_amounts
      puts "==> Preparing EngineeringCompanyMedicalInsuranceAmount"
      ::EngineeringCompanyMedicalInsuranceAmount.destroy_all

      dates = %w(2000-01-01 2014-01-01 2014-07-01 2015-01-01)
      amounts = [0, 100, 200, 249]

      dates.each_with_index do |start_date, idx|
        next_date = dates[idx+1]
        end_date = next_date.to_date.yesterday rescue nil
        ::EngineeringCompanyMedicalInsuranceAmount.create!(
          start_date: Date.parse(start_date),
          end_date: end_date,
          amount: amounts[idx]
        )
      end
    end

end

Engineer.start(ARGV)
