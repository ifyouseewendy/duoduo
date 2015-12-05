require_relative 'duoduo_cli'

class EngineerSeal < DuoduoCli
  attr_reader :file, :xlsx, :sheet

  desc 'start', ''
  option :from, required: true
  def start
    load_rails
    init_logger
    clean_db

    logger.info "[#{Time.now}] Import start"

    set_file load_from(options[:from])
    parse_file

    logger.info "[#{Time.now}] Import end"
  end

  private

    def clean_db
      SealTable.destroy_all
    end

    def set_file(path)
      @file = path
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def set_sheet
      @sheet = xlsx.sheet(0).to_a
    end

    def parse_file
      set_xlsx
      set_sheet

      headers = sheet[0].compact.map{|h| h.strip.gsub(/\s+/, ' ') }
      tables = headers.map{|h| SealTable.create!(name: h)}
      sheet[2..-1].each do |row|
        row.in_groups_of(2).each_with_index do |(nest_index, name), idx|
          next if nest_index.blank?

          tables[idx].seal_items.create(nest_index: nest_index.to_i, name: name)
        end
      end
    end
end

EngineerSeal.start(ARGV)
