require_relative 'duoduo_cli'

class BusinessSalary < DuoduoCli
  attr_reader :file, :corporation, :xlsx, :table

  desc "test", ''
  def test
    load_rails
    init_logger

    logger.info "Test from Business thor"
  end

  desc "start", ''
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/business_salary.rb start --from=/Users/wendi/Downloads/电力/伊通电力/2015年伊通电力工资表.xls
  LONGDESC
  option :from, required: true
  def start
    load_rails

    # Skip callbacks
    SalaryItem.skip_callback(:create, :before, :auto_init_fields)
    SalaryItem.skip_callback(:save, :after, :revise_fields)
    SalaryItem.skip_callback(:destroy, :after, :revise_nest_index)

    clean_db(:business_salary)

    clean_logger
    init_logger

    logger.info "[#{Time.now}] Import start"

    path = load_from(options[:from])
    if path.directory?
      # 电力
      #   - 伊通电力
      #     - 2015年伊通电力工资表.xls
      #     - __2015年伊通电力工资表.xls
      #   - 供电维修
      #     - 2015年供电维修工资表.xls
      #     - __2015年供电维修工资表.xls
      sub_folders = path.entries.reject{|en| en.to_s.start_with?('.')}
      files = sub_folders.flat_map do |sf|
        path.join(sf).entries
          .reject{|pa| pa.to_s.start_with?('.') or pa.to_s.start_with?('__')}
          .flat_map{|pa| path.join(sf).join(pa)}
      end
    else
      files = Array.wrap(path)
    end

    $NULL_ID = 222222222222222222
    zheqi_staff.destroy
    NormalStaff.where("identity_card like ?", '22222222222222%%%%').each(&:destroy)

    files.each do |f|
      logger.info "--> Processing #{f.basename}"

      set_file(f)
      set_corporation
      parse_file
    end

    logger.info "[#{Time.now}] Import end"
  end

  private

    def parse_file
      set_xlsx

      preprocess_xlsx.each do |_, info|
        create_table(name: info[:gai][:name])

        info.each do |type, ha|
          process_table(type: type, name: ha[:name], sheet: ha[:sheet])
        end
      end
    end

    # Preprocess to a Hash, like
    #
    #   {
    #     "201412" => {
    #       lai: { name: "201412来", sheet: <#Roo::Excel:1774733573436374> },
    #       gai: { name: "201412改（12月工资1月保险）", sheet: <#Roo::Excel:1774733573436374> },
    #       daka: { name: "201412打卡", sheet: <#Roo::Excel:1774733573436374> }
    #     },
    #     "201501" => { ... },
    #     ...
    #   }
    def preprocess_xlsx
      xlsx.sheets.each_with_index.reduce({}) do |ha, (name, idx)|
        if name.start_with?('Sheet')
          ha
        else
          key = name.strip.match(/^\d{6}/).to_s

          if key.length != 6
            if name.index('月打卡')
              month = name.strip.match(/^\d+/).to_s
              month.prepend('0') if month.length == 1
              key = month.prepend('2015')
            else
              logger.error "#{file.basename} ; 无法解析工资表名称：#{name}"
              raise "#{file.basename} ; 无法解析工资表名称：#{name}"
            end
          end

          # 201501改（2）
          if data=name.strip.match(/（\d{1}）/)
            key += "#{data}"
          end

          # 201501改（补发）
          if name.index '补发'
            key += '补'
          end

          ha[key] ||= {}

          type  = parse_type(name: name)
          # puts "#{key} - #{type} - #{xlsx.sheet(idx).to_a[0].join(',')}"
          ha[key][type] = { name: name, sheet: xlsx.sheet(idx).to_a }

          ha
        end
      end
    end

    def set_file(path)
      @file = path
    end

    def set_corporation
      name = file.basename.to_s.split('.')[0]
      @corporation = NormalCorporation.where(name: name).first
      raise "未找到合作单位名称：#{name}" if @corporation.nil?
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def create_table(name:)
      date = get_start_date_from(name)
      @table = corporation.salary_tables.find_or_create_by!(name: name, start_date: date)
      corporation.active!
    end

    def process_table(type:, name:, sheet:)
      case type
      when :lai
        process_table_lai(name: name, sheet: sheet)
      when :gai
        process_table_gai(name: name, sheet: sheet)
      when :daka
        process_table_daka(name: name, sheet: sheet)
      else
        logger.error "#{file.basename} ; 无法解析工资表类型：#{type}"
      end
    end

    def process_table_lai(name:, sheet:)
      filepath = Rails.root.join("tmp").join("#{name}.xlsx")

      begin
        Axlsx::Package.new do |pkg|
          pkg.workbook.add_worksheet do |sht|
            sheet.each do |row|
              sht.add_row row
            end
          end
          pkg.serialize(filepath.to_s)
        end

        table.lai_table = File.open(filepath)
        table.save!
      ensure
        filepath.unlink
      end
    end

    def process_table_gai(name:, sheet:)
      header_row = 2
      start_row = header_row + 1
      sum_row = nil
      last_staff = nil
      items = []

      fields = sheet[header_row].compact.map do |col|
        FIELD[col.delete(' ')].tap do |fd|
          if fd.blank?
            logger.error "#{file.basename} ; #{name} ; 无法判断的列名：#{col}"
            return
          end
        end
      end

      skip_total = false
      counter = 0

      sheet[start_row..-1].each_with_index do |data, idx|
        if ['合计', '总计'].include? data.compact[0].to_s.delete(' ')
          sum_row = start_row + idx
          break
        end

        next if data.compact.blank?

        stats = Hash[fields.zip(data)]
        staff_name = stats[:name].try(:delete, ' ')
        account = stats[:bank_account].try(:delete, ' ')

        begin
          item = table.salary_items.new \
            stats.reject{|k| %i(id bank_account name social_insurance_base medical_insurance_base identity_card null_field).include? k}
        rescue => e
          logger.error "#{file.basename} ; #{name} ; #{e.message}"
        end

        role = :normal

        if staff_name.blank?
          if account.try(:index, '喆琦')
            staff = zheqi_staff
            role = :transfer
          else
            if account.blank?
              staff = last_staff
              role = :transfer
            elsif stf = corporation.normal_staffs.where(account: account).first
              staff = stf
            else
              logger.error "#{file.basename} ; #{name} ; 姓名为空，并且找不到银行卡 #{account}"
              skip_total = true
              next
            end
          end
        elsif staff_name.index('喆琦')
          staff = zheqi_staff
          staff.update_attribute(:account, account) if account.present? && account.match(/^\d+$/)

          role = :transfer
        elsif staff_name == last_staff.try(:name)
          staff = last_staff
          role = :transfer
        else
          begin
            staff = SalaryItem.find_staff(salary_table: table, name: staff_name)
          rescue => e
            if String === data[-1] && data[-1].match(/\d{10}/)
              # 附加身份证号
              staff = NormalStaff.where(identity_card: data[-1].strip).first
            elsif (ns=NormalStaff.where(account: data[1]).first).present?
              staff = ns
            end

            # logger.error "#{file.basename} ; #{name} ; #{e.message}"

            # staff = corporation.normal_staffs.where(name: staff_name).first

            if staff.blank?
              logger.error "#{file.basename} ; #{name} ; 自动创建员工，#{e.message}"

              staff = corporation.normal_staffs.create!(name: staff_name, identity_card: $NULL_ID , in_service: true)
              $NULL_ID += 1
              staff.labor_contracts.create!(
                in_contract: true,
                has_social_insurance: true,
                has_medical_insurance: true,
                social_insurance_base: 1861.15,
                medical_insurance_base: 3102.0,
                normal_corporation_id: corporation.id,
                remark: '导入时创建'
              )
            end
          end

          staff.update_attribute(:account, account) if staff.account.nil? && account.present?
        end

        if (contract=staff.try(:labor_contract)) && (stats[:social_insurance_base].present? || stats[:medical_insurance_base].present?)
          contract.social_insurance_base = stats[:social_insurance_base] if stats[:social_insurance_base].present?
          contract.medical_insurance_base = stats[:medical_insurance_base] if stats[:medical_insurance_base].present?
          contract.save!
        end

        last_staff = staff

        item.role = role
        counter += 1 if role == :normal
        item.nest_index = counter

        item.normal_staff = staff
        item.staff_name = staff.name
        item.staff_account = staff.account

        item.save!

        items << item
      end

      if sum_row.present? && !skip_total
        summary = Hash[ fields.zip(sheet[sum_row]) ].reject{|k| %i(id bank_account name remark social_insurance_base medical_insurance_base identity_card null_field).include? k}
        summary.each do |k, v|
          sum = items.map{|it| it.send(k).to_f }.sum.round(2)
          if sum != v.to_f.round(2)
            logger.error "#{file.basename} ; #{name} ; 合计金额不等，#{FIELD[k]}: #{sum}"
          end
        end
      end

      remark_row = nil
      sum_row ||= 0
      sheet[(sum_row+1)..-1].each_with_index do |data, idx|
        if data.compact[0].try(:index, '备注')
          remark_row = sum_row+1+idx
          break
        end
      end

      if remark_row.present?
        remarks = sheet[(remark_row+1)..-1].reduce([]) do |remark, data|
          if data.all?(&:blank?)
            remark
          else
            remark << data.join
          end
        end

        table.update_attribute(:remark, remarks.join('；'))
      end

    end

    def process_table_daka(name:, sheet:)
      filepath = Rails.root.join("tmp").join("#{name}.xlsx")

      begin
        Axlsx::Package.new do |pkg|
          pkg.workbook.add_worksheet do |sht|
            sheet.each do |row|
              sht.add_row row
            end
          end
          pkg.serialize(filepath.to_s)
        end

        table.daka_table = File.open(filepath)
        table.save!
      ensure
        filepath.unlink
      end
    end

    def parse_type(name:)
      case name
      when /来/ then :lai
      when /改/ then :gai
      when /打卡/ then :daka
      else
        logger.error "#{file.basename} ; 无法根据工资表名称判断类型：#{name}"
      end
    end

    FIELD = {
      '序号'             => :id,
      '卡号'             => :bank_account,
      '工资卡号'         => :bank_account,
      '身份证号'         => :identity_card,
      '姓名'             => :name,
      '社保基数'         => :social_insurance_base,
      '医保基数'         => :medical_insurance_base,
      '年终奖'           => :annual_reward,
      '应发工资'         => :salary_deserve,
      '应发'             => :salary_deserve,
      '应发工资合计'     => :salary_deserve,

      '养老保险个人'     => :pension_personal,
      '养老保险差额个人' => :pension_margin_personal,
      '失业保险个人'     => :unemployment_personal,
      '失业保险差额个人' => :unemployment_margin_personal,
      '医疗保险个人'     => :medical_personal,
      '医疗保险差额个人' => :medical_margin_personal,
      '公积金个人'       => :house_accumulation_personal,
      '大额'             => :big_amount_personal,
      '个税'             => :income_tax,
      '体检费'           => :physical_exam_addition,
      '其他（个人）'     => :other_personal,

      '扣款'             => :deduct_addition,
      '预扣款'           => :deduct_addition,
      '医保卡'           => :medical_scan_addition,
      '医保扫描'         => :medical_scan_addition,
      '工资卡'           => :salary_card_addition,
      '暂扣工资'         => :salary_deduct_addition,
      '其他（扣款）'     => :other_deduct_addition,

      '个人缴费合计'     => :total_personal,
      '实发工资'         => :salary_in_fact,
      '实发'             => :salary_in_fact,
      '实发工资合计'     => :salary_in_fact,

      '养老保险单位'     => :pension_company,
      '失业保险单位'     => :unemployment_company,
      '医疗保险单位'     => :medical_company,
      '工伤保险单位'     => :injury_company,
      '生育保险单位'     => :birth_company,
      '养老保险差额单位' => :pension_margin_company,
      '失业保险差额单位' => :unemployment_margin_company,
      '医疗保险差额单位' => :medical_margin_company,
      '工伤保险差额单位' => :injury_margin_company,
      '生育保险差额单位' => :birth_margin_company,
      '公积金单位'       => :house_accumulation_company,
      '意外险'           => :accident_company,
      '其他（单位）'     => :other_company,

      '单位缴费合计'     => :total_company,
      '单位保险合计'     => :total_company,
      '管理费'           => :admin_amount,
      '劳务费用合计'     => :total_sum_with_admin_amount,

      '备注'             => :remark,

      '工作地'           => :null_field
    }

    def zheqi_staff
      NormalStaff.where(name: '喆琦').first \
        || NormalStaff.create!(
              name: '喆琦',
              identity_card: '333333333333333333',
              in_service: true,
              normal_corporation_id: NormalCorporation.internal.id
            )
    end

    def get_start_date_from(name)
      Date.parse(name.match(/^\d{6}/)[0] + "01")
    end
end

BusinessSalary.start(ARGV)
