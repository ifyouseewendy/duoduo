require_relative 'duoduo_cli'

class Business < DuoduoCli
  attr_reader :file, :corporation, :xlsx, :table

  desc "test", ''
  def test
    load_rails
    init_logger

    logger.info "Test from Business thor"
  end

  desc "salary", ''
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/business.rb salary --from=/Users/wendi/Downloads/电力/伊通电力/2015年伊通电力工资表.xls
  LONGDESC
  option :from, required: true
  def salary
    load_rails
    init_logger

    set_file load_from(options[:from])
    set_corporation
    parse_file
  end

  private

    def parse_file
      set_xlsx

      xlsx.sheets.each_with_index do |name, idx|
        generate_table(name: name, sheet: xlsx.sheet(idx))
      end
    end

    def set_file(path)
      @file = path
    end

    def set_corporation
      name = file.basename.to_s.split('.')[0]
      @corporation = NormalCorporation.find_or_create_by!(name: name)
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def generate_table(name:, sheet:)
      parts = name.split(/(^\d+)/)[1,2]
      month = parts[0].to_sym
      type  = parse_table_type(name: parts[1])

      create_table(name: month)

      process_table(type: type, sheet: sheet)
    end

    def set_table(name:)
      @table = corporation.salary_tables.create!(name: month)
    end

    def process_table(type:, sheet:)
      case type
      when :lai
        process_table_lai(sheet: sheet)
      when :gai
        process_table_gai(sheet: sheet)
      when :daka
        process_table_daka(sheet: sheet)
      else
        fail "无法解析工资表类型：#{type}"
      end
    end

    def process_table_lai(sheet:)
    end

    def process_table_gai(sheet:)
    end

    def process_table_daka(sheet:)
    end

    def parse_table_type(name:)
      case name
      when /来/ then :lai
      when /改/ then :gai
      when /打卡/ then :daka
      else
        fail "无法根据工资表名称判断类型：#{name}"
      end
    end

end

Business.start(ARGV)
