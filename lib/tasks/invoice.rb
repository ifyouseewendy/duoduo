require_relative 'duoduo_cli'

class InvoiceThor < DuoduoCli
  attr_reader :file, :xlsx, :sub_company, :category, :invoice_setting

  desc 'start', ''
  option :from, required: true # 文件名为子公司名称
  def start
    load_rails
    clean_logger
    init_logger

    logger.info "[#{Time.now}] Import start"

    path = load_from(options[:from])
    if path.directory?
      files = path.entries.reject{|en| en.to_s.start_with?('.')}.map{|en| path.join(en)}
    else
      files = Array.wrap(path)
    end

    files.each do |f|
      logger.info "#{f.basename}"

      set_file(f)
      parse_file
    end

    logger.info "[#{Time.now}] Import end"
  end

  private

    def set_file(path)
      @file = path
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def set_sub_company
      @sub_company ||= SubCompany.where(name: '吉易人力资源').first
    end

    def set_category
      @category = 'normal'
    end

    def set_invoice_setting
      sheet = xlsx.sheet(0)
      data = sheet.to_a[1..-1]

      start_encoding = data[0][2]
      raise "Invalid start_encoding #{start_encoding}" unless start_encoding.match(/^\d*$/)
      end_encoding = data.reverse.detect{|row| row[2].present? }[2]
      raise "Invalid end_encoding #{end_encoding}"  unless end_encoding.match(/^\d*$/)

      Invoice.where("encoding >= ? and encoding <= ?", start_encoding, end_encoding).destroy_all

      # count = end_encoding.to_i - start_encoding.to_i + 1
      @invoice_setting = sub_company.invoice_settings.where(start_encoding: start_encoding).first
      raise "No invoice_setting" if @invoice_setting.nil?
      @invoice_setting.update_columns(last_encoding: nil, used_count: 0, status: 0)
    end

    def parse_file
      set_xlsx
      set_sub_company
      set_invoice_setting

      sheet      = xlsx.sheet(0)
      data       = sheet.to_a[1..-1]
      group_data = data.slice_when{|a,b| b[0].present? }.to_a[0..-2]

      last_invoice = nil
      group_data.each do |rows|
        date, code, encoding, payer, _fee_name, fee, total_amount, contact, refund_person, income_date, refund_date = rows[0]

        if rows.count == 1
          admin_amount = 0
          amount = fee.to_f.round(2)
        elsif rows.count == 2
          admin_amount = fee.to_f.round(2)
          amount = rows[1][5].to_f.round(2)
        else
          raise "Multiple rows #{row}"
        end

        contact ||= last_invoice.try(:contact)

        scope = 'business'
        scope = 'engineer' if contact.to_s.match(/^\d+/)

        if payer.index('作废')
          status = 'cancel'
        else
          status = 'work'
        end

        category = 'normal'

        invoice = Invoice.create!(
          sub_company: sub_company,
          date: date,
          code: code.try(:strip),
          encoding: encoding.try(:strip),
          category: category,
          scope: scope,
          payer: payer.try(:strip),
          amount: amount,
          admin_amount: admin_amount,
          contact: contact.try(:strip),
          income_date: income_date,
          refund_person: refund_person.try(:strip),
          refund_date: refund_date,
          status: status
        )

        puts "Unequal total amount, encoding: #{encoding}" unless invoice.total_amount.to_f.round(2) == total_amount.to_f.round(2)

        invoice_setting.increment_used!
        last_invoice = invoice
      end
    end
end

InvoiceThor.start(ARGV)

