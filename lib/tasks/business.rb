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
    clean_db(:business)
    init_logger

    set_file load_from(options[:from])
    set_corporation
    parse_file
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
        key = name.strip.match(/^\d+/).to_s
        ha[key] ||= {}

        type  = parse_type(name: name)
        # puts "#{key} - #{type} - #{xlsx.sheet(idx).to_a[0].join(',')}"
        ha[key][type] = { name: name, sheet: xlsx.sheet(idx).to_a }

        ha
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

    def create_table(name:)
      @table = corporation.salary_tables.find_or_create_by!(name: name)
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
        fail "无法解析工资表类型：#{type}"
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
    end

    def process_table_daka(name:, sheet:)
    end

    def parse_type(name:)
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
