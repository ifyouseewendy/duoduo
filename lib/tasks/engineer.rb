require_relative 'duoduo_cli'

class Engineer < DuoduoCli
  attr_reader :logger, :customer_dir, :customer, :project_info, :project_info_xlsx, :projects

  desc "batch_start", ''
  option :from, required: true
  def batch_start
    fail "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails
    init_logger
    clean_db(:engineer)

    logger.info "[#{Time.now}] Import start"

    dir = Pathname(options[:from])
    dir.entries.sort.each do |entry|
      next if skip_file?(entry)

      self.class.new.invoke('start', [], from: dir.join(entry), batch: true )
    end

    logger.info "[#{Time.now}] Import end"
  end

  desc "start", "Import engineering data"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/engineer.rb start --from=
  LONGDESC
  option :from, required: true
  option :batch
  def start
    unless options[:batch]
      load_rails
      clean_db(:engineer)
    end

    init_logger
    logger.level = Logger::ERROR
    logger.info "[#{Time.now}] Import start"

    set_customer_dir load_from(options[:from])
    logger.info "- #{customer_dir.basename}"

    # 信息汇总
    set_projects process_project_infos

    # 提供人员
    process_provide_staff_dir

    # 项目
    iterate_projects
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
      else
        logger.error "xxx 无法解析子公司名称: #{name}"
        nil
      end
    end

    def parse_project_dates(str)
      fail "xxxxx 无法解析工程日期: #{str} #{project_info}" if str.split('-').count > 2

      start_date, end_date = str.split('-')

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
          parts.unshift year
          parts.push '1'
        else
          fail "xxxxx 无法解析工程结束日期：#{end_date} #{project_info}"
        end

        end_date = Date.parse parts.join('.')
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
        logger.error "xxxxx 无法解析工程开始日期：#{date} ; #{project_info}"
        raise e
      end
    end

    def split_by_comma(string)
      string.to_s.split(',').map(&:strip)
    end

    def process_provide_staff_file(file)
      logger.info "----- #{file.basename}"

      xlsx = Roo::Spreadsheet.open(file.to_s)
      sheet = xlsx.sheet(0).to_a

      sheet[2..-1].each do |data|
        _id, name, gender, identity_card, remark = \
          data.map{|col| String === col ? col.strip : col}

        next if _id.nil?

        gender_map = {'男' => 0, '女' => 1}

        begin
          staff = EngineeringStaff.where(identity_card: identity_card).first

          if staff.present?
            if staff.engineering_customer.id != customer.id
              logger.error "----- 员工（#{staff.name} - #{identity_card}）属于客户（#{staff.engineering_customer.name}），又出现在客户（#{customer.name}）的提供人员中 ; #{file}"
            end
          else
            staff = EngineeringStaff.create!(
              engineering_customer: customer,
              name: name,
              gender: gender_map[gender],
              identity_card: identity_card,
              remark: remark
            )
          end

        rescue => e
          logger.info "----- #{e.message} #{name}"
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
      @customer = EngineeringCustomer.find_or_create_by!(name: customer_dir.basename.to_s)
    end

    def process_project_infos
      files = get_project_info_files

      logger.error "xxx 没有信息汇总 ; #{customer_dir}" and return \
        if files.blank?

      files.reduce({}) do |ha, file|
        set_project_info(file)
        stats = process_project_info
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

      add_sub_company_to_customer(sc)

      set_project_info_xlsx
      process_project_info_xlsx
    end

    def add_sub_company_to_customer(sc)
      customer.sub_companies << sc
    end

    def set_project_info_xlsx
      @project_info_xlsx = Roo::Spreadsheet.open(project_info.to_s)
    end

    def process_project_info_xlsx
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
          logger.error "无法解析信息汇总：错误的列数 #{column_count} ; #{project_info}"
          break
        end

        begin
          project_start_date, project_end_date = parse_project_dates(project_dates.to_s)
        rescue => _
          logger.error "无法解析工程起止日期：#{project_dates} ; #{project_info}"
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

        logger.error "校验失败：劳务费加管理费不等于费用合计，id: #{id.to_i} ; #{project_info}"\
          unless equal_value?(project.total_amount, total_amount)

        projects[id.to_i] = project
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
        if k == :outcome_amount
          logger.error "xxxxx 校验失败: #{total_i18n[k]} #{v} ; #{project_info}" \
            unless equal_value?(v, projects.values.map{|pr| pr.outcome_items.map(&:amount).sum }.sum)
        else
          logger.error "xxxxx 校验失败: #{total_i18n[k]} #{v} ; #{project_info}" \
            unless equal_value?(v, projects.values.map(&k).map(&:to_f).sum)
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

    def iterate_projects
      customer_dir.entries.sort.each do |pn|
        next if skip_file?(pn) or special_file?(pn)

        logger.info "--- #{pn}"

        id, _name = pn.to_s.split('、')
        project = projects[id.to_i]

        logger.info "----- 特例跳过" and next if project.blank?

        dir = customer_dir.join(pn)

        staff_files    = find_in_project_dir(dir: dir, type: :staff)
        contract_files = find_in_project_dir(dir: dir, type: :contract)
        proxy_files    = find_in_project_dir(dir: dir, type: :proxy)
        salary_files   = find_in_project_dir(dir: dir, type: :salary)

        process_staff_files(staff_files, project)
        process_contract_files(contract_files, project)
        process_proxy_files(proxy_files, project)
        process_salary_files(salary_files, project)
      end
    end

    def find_in_project_dir(dir:, type:)
      files = \
        case type.to_sym
        when :staff
          dir.entries.select{|file| file.to_s =~ /用工/ or file.to_s =~ /明细表/ }
        when :contract
          dir.entries.select{|file| file.to_s =~ /合同/}
        when :proxy
          dir.entries.select{|file| file.to_s =~ /协议/}
        when :salary
          dir.entries.select{|file| file.to_s =~ /工资/}
        else
          logger.error "xxxxx 无法解析项目内文件 ; #{dir}"
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

        begin
          staff = customer.engineering_staffs.where(identity_card: identity_card).first

          if staff.present?
            if staff.name != name.delete(' ')
              logger.error "----- 已找到员工（#{staff.name} - #{identity_card}），用工明细中显示为其他姓名（#{name.delete(' ')}）;  #{file}"
            end
          else
            logger.error "----- 员工（#{name.delete(' ')} - #{identity_card}）未在客户（#{customer.name}）的提供人员中出现 ; #{file}"

            staff2 = EngineeringStaff.where(identity_card: identity_card).first

            if staff2.present?
              logger.error "----- 员工（#{staff2.name} - #{identity_card}）属于客户（#{staff2.engineering_customer.name}） ; #{file}"
            else
              gender_map = {'男' => 0, '女' => 1}
              staff = EngineeringStaff.create!(
                engineering_customer: project.engineering_customer,
                name: name.delete(' '),
                gender: gender_map[gender],
                identity_card: identity_card
              )
            end
          end
          staff.engineering_projects << project
        rescue => e
          logger.info "----- #{e.message} #{name}"
        end
      end
    end

    def process_contract_files(files, project)
      files.each do |file|
        logger.info "----- #{file.basename}"
        set_project_date_range(project: project, path: file)
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
        line = data.delete(' ').split.detect{|str| str =~ /[劳动|派遣]期间/  }
        parts = line.split(/[自|至|止]/)

        start_date = convert_chinese_date(parts[1])
        logger.error "----- 无法通过合同判断起始日期：#{start_date} ; #{path}" if start_date.blank?
        end_date = convert_chinese_date(parts[2])
        logger.error "----- 无法通过合同判断终止日期：#{end_date} ; #{path}" if end_date.blank?

        if project.range != [start_date, end_date]
          logger.info "----- 解析合同文件，并更新项目起止日期。合同：#{project.range.map(&:to_s).join(' ~ ')}，汇总：#{[start_date, end_date].map(&:to_s).join(' ~ ')}"
        end
        project.update_attributes(project_start_date: start_date, project_end_date: end_date)
      end
    end

    def convert_chinese_date(date)
      words = date.split(/[年|月|日]/)
      return nil unless Date.valid_date?(*words.map(&:to_i))

      Date.parse words.join('.')
    end

    def process_proxy_files(files, project)
      files.each do |file|
        logger.info "----- #{file.basename}"
        project.add_contract_file(path: file, role: :proxy)
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

      ranges = project.split_range(xlsx.sheets.count)

      xlsx.sheets.each_with_index do |sheet_name, sheet_id|
        logger.info "------- Sheet #{sheet_id+1}"
        sheet = xlsx.sheet(sheet_id)

        if sheet.row(3).compact.count == 1
          start_row = 5
        elsif sheet.row(2).compact.count == 1
          start_row = 4
        elsif sheet.row(1).compact.count == 1
          start_row = 3
        else
          logger.error "xxxxxxx 无法解析工资表：#{sheet_name} ; #{path}"
          next
        end

        col_count = sheet.row(start_row-1).compact.count
        if col_count == 10
          type = 'EngineeringNormalWithTaxSalaryTable'
        end

        start_date, end_date = ranges[sheet_id]

        st = EngineeringSalaryTable.create!(
          engineering_project: project,
          name: [start_date, end_date].join(' ~ '),
          start_date: start_date,
          end_date: end_date,
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
              logger.error "xxxxxxx 无法解析工资表，错误的列数 #{col_count} ; #{path}"
              next
            end

            total_i18n = {
              salary_deserve: '应发工资',
              social_insurance: '税金',
              salary_in_fact: '实发工资'
            }

            total.each do |k,v|
              logger.error "xxxxxxx 校验失败：#{total_i18n[k]} #{v.to_f} ; #{path}" \
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
            logger.error "xxxxxxx 无法解析工资表，错误的列数 #{col_count}: #{sheet_name} ; #{path}"
            next
          end

          next if id.nil?

          name = name.delete(' ')
          staff = project.engineering_staffs.where(name: name).first
          if staff.nil?
            logger.error "xxxxxxx 未找到员工: #{name} ; #{path}"
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
end

Engineer.start(ARGV)
