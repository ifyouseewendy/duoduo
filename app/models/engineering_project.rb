class EngineeringProject < ActiveRecord::Base
  belongs_to :engineering_customer
  belongs_to :engineering_corp
  has_and_belongs_to_many :engineering_staffs

  has_many :engineering_salary_tables, dependent: :destroy

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy, as: :engi_contract

  has_many :income_items, class: EngineeringIncomeItem, dependent: :destroy, after_add: :set_fields
  accepts_nested_attributes_for :income_items, allow_destroy: true
  has_many :outcome_items, class: EngineeringOutcomeItem, dependent: :destroy, after_add: :set_fields
  accepts_nested_attributes_for :outcome_items, allow_destroy: true

  before_save :revise_fields

  enum status: [:active, :archive]

  class << self
    def policy_class
      EngineeringPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_customer_id engineering_corp_id) if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)
      hash = {
        'engineering_customer_id_工程客户' => EngineeringCustomer.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]},
        'engineering_corp_id_工程单位' => EngineeringCorp.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]}
      }
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.#{name.underscore}")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      booleans = columns_of(:boolean)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                if [:engineering_customer, :engineering_corp].include? col
                  item.send(col).name
                elsif booleans.include? col
                  item.send(col) ? '是' : '否'
                else
                  item.send(col)
                end
              end
              sheet.add_row stats
          end
        end
        p.serialize(filepath.to_s)
      end

      filepath
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        %i(id name engineering_customer engineering_corp) \
          + (ordered_columns(without_foreign_keys: true) - %i(id name))
      end
    end

    def nest_fields
      [:income_date, :income_amount, :outcome_date, :outcome_referee, :outcome_amount]
    end

    def id_name_option
      self.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]}
    end
  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def revise_fields
    if (changed & ['project_start_date', 'project_end_date']).present?
      self.project_range = -> {
        month, day = calc_range

        range = ''
        range += "#{month} 个月 " if month > 0
        range += "#{day} 天" if day > 0
        range
      }.call
    end

    if (changed & ['project_amount', 'admin_amount']).present?
      self.total_amount = project_amount + admin_amount
    end
  end

  def set_fields(outcome_item)
    # First time assign outcome_item
    if !self.already_sign_dispatch && outcome_items.count == 1
      self.update_column(:already_sign_dispatch, true) # Skip validation and callback
    end

    if can_archive?
      self.archive!
    end
  end

  def can_archive?
    income_amount.map(&:to_f).sum.round(2) == total_amount.round(2) \
      && outcome_amount.map(&:to_f).sum.round(2) == project_amount.round(2)
  end

  def calc_range
    start_date, end_date = project_start_date.to_date, project_end_date.to_date
    month = 0

    while (start_date + 1.month - 1.day) <= end_date
      month += 1
      start_date += 1.month
    end

    day = (end_date - start_date).to_i

    [month, day]
  end

  def range
    [project_start_date, project_end_date]
  end

  def range_output
    "项目：#{name}，起止日期：#{project_start_date} - #{project_end_date}"
  end

  def generate_salary_table(need_count:)
    month, day = calc_range
    table_count = month + ( day > 0 ? 1 : 0 )
    salaries = gennerate_random_salary(amount: project_amount, count: need_count*table_count)
    pos = 0

    own_staffs = engineering_staffs.limit(need_count).to_a
    new_staffs = []
    if own_staffs.count < need_count
      new_count = need_count - own_staffs.count

      if new_count > 0
        new_staffs = engineering_customer.free_staffs( *(range << new_count) )

        new_staffs.each do |staff|
          self.engineering_staffs << staff
        end
      end
    end

    staffs = own_staffs + new_staffs

    start_date, end_date = project_start_date.to_date, project_end_date.to_date
    (1..table_count).each do |idx|
      month_end_date = start_date + 1.month - 1.day
      month_end_date = end_date if idx == table_count

      st = EngineeringNormalSalaryTable.create!(
        engineering_project: self,
        name: "#{start_date} ~ #{month_end_date}"
      )

      staffs.each do |staff|
        salary = salaries[pos]
        pos += 1

        st.salary_items.create_by(table: st, staff: staff, salary_in_fact: salary)
      end

      start_date += 1.month
    end
  end

  def gennerate_random_salary(amount:, count:)
    fraction_gap = amount.ceil - amount
    amount = amount.ceil

    tax_limit = 3500
    raise "Value of #{amount}<amount> is too big, higher than #{tax_limit*count} ( = #{count}<count> * #{tax_limit}<tax_limit> )" if amount > count*tax_limit

    lower_bound = EngineeringCompanySocialInsuranceAmount.order(amount: :desc).first.amount \
      + EngineeringCompanyMedicalInsuranceAmount.order(amount: :desc).first.amount
    raise "Value of #{amount}<amount> is too small, lower than #{lower_bound*count} ( = #{count}<count> * #{lower_bound}<lower_bound> )" if amount < count*lower_bound

    amount, count = [amount, count].map(&:to_i)

    avg = amount / count
    mod = amount % count

    max_wave = tax_limit - avg
    min_wave = avg - lower_bound
    wave = [max_wave, min_wave].min

    wave_array = [1]*mod + [0]*(count-mod)

    pos = 0
    while pos + 1 < count
      num = wave > 0 ? rand(wave) : 0

      wave_array[pos] += num
      wave_array[pos+1] += 0 - num

      pos += 2
    end

    wave_array[0] = (wave_array[0] - fraction_gap).round(2)
    wave_array.map{|n| avg + n}.shuffle
  end


  def generate_salary_table_with_tax(file:)
    raise '导入失败（未找到文件），请选择上传文件' if file.nil?

    raise '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)

    stats = (1..sheet.last_row).reduce([]) do |ar, row|
      name, salary = sheet.row(row).to_a
      name.strip!

      staff = engineering_staffs.where(name: name).first
      if staff.nil?
        staff = engineering_customer.engineering_staffs.where(name: name).first
        self.engineering_staffs << staff if staff.present?
      end

      raise "导入失败，未找到员工<#{name}>" if staff.nil?

      ar << {staff: staff, salary: salary}
    end

    st = EngineeringNormalWithTaxSalaryTable.create!(
      engineering_project: self,
      name: "#{range.join(' ~ ')}"
    )

    stats.each do |stat|
      st.salary_items.create_by(table:st, staff:stat[:staff], salary_deserve:stat[:salary])
    end
  end

  def generate_salary_table_big(url:)
    uri = URI(url)
    url = [uri.path, uri.query].join('?')

    EngineeringBigTableSalaryTable.create!(
      engineering_project: self,
      name: "#{range.join(' ~ ')}",
      reference: EngineeringBigTableSalaryTableReference.create!(url: url)
    )
  end

  def add_contract_file(path:, role: :normal)
    self.contract_files.create!(
      contract: File.open(path),
      role: role
    )
  end

  def income_date
    income_items.map(&:date).map(&:to_s)
  end

  def income_amount
    income_items.map(&:amount).map(&:to_s)
  end

  def outcome_date
    outcome_items.map(&:date).map(&:to_s)
  end

  def outcome_referee
    outcome_items.map(&:persons).map{|ps| ps.join(',')}
  end

  def outcome_amount
    outcome_items.map(&:amount).map(&:to_s)
  end

  def generate_contract_file(sub_company:, role:, outcome_item_id:, content: {})
    role = role.to_sym
    raise "错误的参数，role: #{params[:rold]}" unless %i(normal proxy).include?(role)

    if role == :normal
      template = sub_company.engi_contract_template
      raise "操作失败：未找到模板文件，请到 /sub_companies/#{sub_company.id} 页面上传模板"\
        if template.file.nil?

      contract =  DocGenerator.generate_docx \
        gsub: content,
        file_path: template.path

      ext = contract.basename.to_s.split('.')[-1]
      to = contract.dirname.join("劳务派遣协议_#{Time.stamp}.#{ext}")
      contract.rename(to)

      add_contract_file(path: to, role: role)
    else
      template = sub_company.engi_protocol_template
      raise "操作失败：未找到模板文件，请到 /sub_companies/#{sub_company.id} 页面上传模板"\
        if template.file.nil?

      outcome_item = EngineeringOutcomeItem.find(outcome_item_id)

      set_amount = content[:amount].split(' ').map(&:to_f)
      amount = \
        if set_amount.count == 1
          outcome_item.allocate(money: set_amount[0])
        else
          set_amount
        end

      raise "操作失败：自定义回款金额之和（#{amount.sum.round(2)}）不等于当前回款记录中的回款金额（#{outcome_item.amount.to_f.round(2)}）" \
        unless outcome_item.amount.to_f.round(2) == amount.sum.round(2)

      bank = content[:bank].split(' ').map(&:strip)
      account = content[:account].split(' ').map(&:strip)
      address = content[:address].split(' ').map(&:strip)

      outcome_item.persons.each_with_index do |person, idx|
        contract =  DocGenerator.generate_docx \
          gsub: {
            corp_name: content[:corp_name],
            person: person,
            amount: amount[idx].to_s,
            money: RMB.new(amount[idx]).convert,
            bank: bank[idx],
            account: account[idx],
            address: address[idx]
          },
          file_path: template.path


        ext = contract.basename.to_s.split('.')[-1]
        to = contract.dirname.join("代发劳务费协议_#{person}_#{Time.stamp}.#{ext}")
        contract.rename(to)

        outcome_item.add_contract_file(path: to)
      end

    end
  end

  ransacker :sub_company, formatter: ->(qid) {
    # ids = User.search_in_all_translated(search).map(&:id)
    # ids = ids.any? ? ids : nil
    sub_company = SubCompany.find(qid)
    sub_company.engineering_customers.select(:id).flat_map{|ec| ec.engineering_projects.pluck(:id)}
  } do |parent|
      parent.table[:id]
  end

end
