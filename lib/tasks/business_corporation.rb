require_relative 'duoduo_cli'

class BusinessCorporation < DuoduoCli
  attr_reader :file, :mapping_file, :xlsx, :mapping_xlsx

  desc "test", ''
  def test
    load_rails
    init_logger

    logger.info "Test from Business thor"
  end

  desc "start", ''
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/business_corporation.rb start --from= --mapping-from=
  LONGDESC
  option :from, required: true
  option :mapping_from, required: true
  def start
    load_rails
    clean_db(:business)
    init_logger

    logger.info "[#{Time.now}] Import start"

    set_file load_from(options[:from])
    parse_file

    set_mapping_file load_from(options[:mapping_from])
    parse_mapping_file

    seed_internal_corporation

    logger.info "[#{Time.now}] Import end"
  end

  private

    def set_file(path)
      @file = path
    end

    def set_mapping_file(path)
      @mapping_file = path
    end

    def set_xlsx
      @xlsx = Roo::Spreadsheet.open(file.to_s)
    end

    def set_mapping_xlsx
      @mapping_xlsx = Roo::Spreadsheet.open(mapping_file.to_s)
    end

    def parse_file
      set_xlsx

      xlsx.sheet(0).to_a.each_with_index do |row, idx|
        next if idx == 0 or idx == 1

        # 单位名称  营业执照号  纳税人识别号  组织代码证号  法人  单位地址  单位账号  单位开户行  单位联系人 单位联系电话  合同签订期限  合同金额  管理费收取方式  管理费收取比例/金额 单位开支日期  备注  吉易子公司
        full_name, license, taxpayer_serial, organization_serial, corporate_name, address, account, account_bank, contact, telephone, contract_dates, contract_amount, admin_charge_type, admin_charge_amount, expense_date, remark, sub_company_name = row.map{|col| String === col ? col.strip : col}

        next if full_name.blank?

        contract_start_date, contract_end_date = *(parse_dates contract_dates)
        sub_company = SubCompany.find_by_name(sub_company_name)

        nc = NormalCorporation.new(
          sub_company: sub_company,
          status: 'archive',
          full_name: full_name,
          license: license,
          taxpayer_serial: taxpayer_serial,
          organization_serial: organization_serial,
          corporate_name: corporate_name,
          address: address,
          account: account,
          account_bank: account_bank,
          contact: contact,
          telephone: telephone.to_i.to_s,
          contract_start_date: contract_start_date,
          contract_end_date: contract_end_date,
          contract_amount: contract_amount,
          admin_charge_type: admin_charge_type,
          admin_charge_amount: admin_charge_amount,
          expense_date: parse_chinese_date(expense_date),
          remark: remark,
        )
        nc.save(validate: false)
      end
    end

    # 2015年02月28日至2016年02月27日
    def parse_dates(str)
      return if str.blank?

      parts = str.split('至')
      parts.map{|part| parse_chinese_date(part)}
    end

    def parse_chinese_date(str)
      Date.parse str.split(/年|月|日/).join('.') rescue nil
    end

    def parse_mapping_file
      set_mapping_xlsx

      special_full_names = ['四平电力设备制造安装有限公司（电力设备）', '中国邮政集团公司四平市分公司']

      mapping_xlsx.sheet(0).to_a.each_with_index do |row, idx|
        next if idx == 0

        # 合作单位名称 合同中全称
        company_name, name, _, full_name = row.map{|col| String === col ? col.strip.delete("\n") : col}
        next if name.blank?

        sub_company = SubCompany.find_by_name(company_name)
        raise "无法找到吉易子公司：#{company_name}" if sub_company.nil?

        if full_name.blank?
          NormalCorporation.create!(
            sub_company: sub_company,
            status: 'archive',
            name: name
          )
        else
          # Ungly patch
          if special_full_names.include?(full_name)
            nc = NormalCorporation.where(full_name: full_name).first
            NormalCorporation.create!(
              nc.attributes.reject{|k| k.to_s == 'id'}.merge({name: name})
            )
          else
            nc = NormalCorporation.where(full_name: full_name).first
            nc = NormalCorporation.new(full_name: full_name) if nc.nil?
            # raise "无法找到合作单位全称：#{full_name}" if nc.nil?

            nc.name = name
            nc.save!
          end
        end
      end

      special_full_names.each do |full_name|
        NormalCorporation.where(full_name: full_name, name: nil).first.delete
      end

      NormalCorporation.where(name: nil).each do |nc|
        nc.update_attribute(:name, nc.full_name)
      end
    end

    def seed_internal_corporation
      NormalCorporation.create!(
        name: '内部'
      )
    end
end

BusinessCorporation.start(ARGV)
