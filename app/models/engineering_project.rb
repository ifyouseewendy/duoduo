class EngineeringProject < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :customer, class: EngineeringCustomer, foreign_key: :engineering_customer_id
  belongs_to :corporation, class: EngineeringCorp, foreign_key: :engineering_corp_id

  has_and_belongs_to_many :staffs, \
    class_name: EngineeringStaff, \
    join_table: 'engineering_projects_staffs'

  has_many :salary_tables, class: EngineeringSalaryTable, dependent: :destroy

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy, as: :engi_contract

  has_many :income_items, class: EngineeringIncomeItem, dependent: :destroy, after_add: :set_fields
  accepts_nested_attributes_for :income_items, allow_destroy: true
  has_many :outcome_items, class: EngineeringOutcomeItem, dependent: :destroy, after_add: :set_fields
  accepts_nested_attributes_for :outcome_items, allow_destroy: true

  before_save :revise_fields

  enum status: [:active, :archive]

  default_scope { order(engineering_customer_id: :asc).order(nest_index: :asc) }
  scope :by_staff, ->(staff_id){
    joins("join engineering_projects_staffs on engineering_projects.id = engineering_projects_staffs.engineering_project_id")\
      .where("engineering_projects_staffs.engineering_staff_id = ?", staff_id)
  }

  validates_uniqueness_of :nest_index, scope: :customer

  class << self
    def policy_class
      EngineeringPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_customer_id engineering_corp_id sub_company_id) if without_foreign_keys

      [:nest_index] + (names - [:nest_index])
    end

    def as_filter
      self.includes(:customer).map do |ep|
        ["#{ep.customer.display_name} - #{ep.display_name}", ep.id]
      end
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
        'engineering_customer_id_工程客户' => EngineeringCustomer.pluck(:name, :id),
        'engineering_corp_id_工程单位' => EngineeringCorp.pluck(:name, :id),
        'sub_company_id_吉易子公司' => SubCompany.hr.pluck(:name, :id)
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
                if [:customer, :corporation, :sub_company].include? col
                  item.send(col).try(:name)
                elsif booleans.include? col
                  item.send(col) ? '是' : '否'
                elsif [:status].include? col
                  item.send(col) == 'active' ? '活动' : '存档'
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
        %i(nest_index name customer corporation sub_company status) \
          + (ordered_columns(without_base_keys: true, without_foreign_keys: true) - %i(nest_index name status))
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

      if corporation.present? && corporation.contract_start_date && corporation.contract_end_date
        # if self.project_start_date < corporation.contract_start_date
        #   errors.add(:project_start_date, "开始日期早于合作单位当前大协议开始日期")
        if self.project_end_date > corporation.contract_end_date
          errors.add(:project_end_date, "晚于合作单位当前大协议结束日期 #{corporation.contract_end_date}")
          return false
        end
      end
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

  def auto_generate_salary_table
    self.class.transaction do
      dates = split_range
      amounts = gennerate_random_salary(amount: self.project_amount, count: dates.count)

      dates.each_with_index do |ar, idx|
        start_date, end_date = ar
        amount = amounts[idx]
        st = self.salary_tables.create!(
          type: 'EngineeringNormalSalaryTable',
          start_date: start_date,
          end_date: end_date,
          amount: amount,
          name: "#{start_date} ~ #{end_date}"
        )

        salaries = gennerate_random_salary(amount: amount, count: staffs.count)
        self.staffs.each_with_index do |staff, id|
          st.salary_items.create!(
            staff: staff,
            salary_in_fact: salaries[id],
            social_insurance: EngineeringCompanySocialInsuranceAmount.query_amount(date: start_date),
            medical_insurance: EngineeringCompanyMedicalInsuranceAmount.query_amount(date: start_date)
          )
        end
      end
    end
  end

  def generate_salary_table(need_count:)
    month, day = calc_range
    table_count = month + ( day > 0 ? 1 : 0 )
    salaries = gennerate_random_salary(amount: project_amount, count: need_count*table_count)
    pos = 0

    own_staffs = staffs.limit(need_count).to_a
    new_staffs = []
    if own_staffs.count < need_count
      new_count = need_count - own_staffs.count

      if new_count > 0
        new_staffs = customer.free_staffs( *(range << new_count) )

        new_staffs.each do |staff|
          self.staffs << staff
        end
      end
    end

    staffs = own_staffs + new_staffs

    start_date, end_date = project_start_date.to_date, project_end_date.to_date
    (1..table_count).each do |idx|
      month_end_date = start_date + 1.month - 1.day
      month_end_date = end_date if idx == table_count

      st = EngineeringNormalSalaryTable.create!(
        project: self,
        name: "#{start_date} ~ #{month_end_date}",
        start_date: start_date,
        end_date: end_date
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
    # raise "Value of #{amount}<amount> is too big, higher than #{tax_limit*count} ( = #{count}<count> * #{tax_limit}<tax_limit> )" if amount > count*tax_limit

    lower_bound = EngineeringCompanySocialInsuranceAmount.order(amount: :desc).first.amount \
      + EngineeringCompanyMedicalInsuranceAmount.order(amount: :desc).first.amount
    # raise "Value of #{amount}<amount> is too small, lower than #{lower_bound*count} ( = #{count}<count> * #{lower_bound}<lower_bound> )" if amount < count*lower_bound

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

      staff = staffs.where(name: name).first
      if staff.nil?
        staff = customer.staffs.where(name: name).first
        self.staffs << staff if staff.present?
      end

      raise "导入失败，未找到员工<#{name}>" if staff.nil?

      ar << {staff: staff, salary: salary}
    end

    st = EngineeringNormalWithTaxSalaryTable.create!(
      project: self,
      name: "#{range.join(' ~ ')}",
      start_date: start_date,
      end_date: end_date
    )

    stats.each do |stat|
      st.salary_items.create_by(table:st, staff:stat[:staff], salary_deserve:stat[:salary])
    end
  end

  def generate_salary_table_big(url:)
    uri = URI(url)
    url = [uri.path, uri.query].join('?')

    EngineeringBigTableSalaryTable.create!(
      project: self,
      name: "#{range.join(' ~ ')}",
      start_date: start_date,
      end_date: end_date,
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

  def generate_contract_file(role:, outcome_item_id:, content: {})
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
      to = contract.dirname.join("#{name}_劳务派遣协议_#{Time.stamp}.#{ext}")
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
        to = contract.dirname.join("#{name}_代发劳务费协议_#{person}_#{Time.stamp}.#{ext}")
        contract.rename(to)

        outcome_item.add_contract_file(path: to)
      end

    end
  end

  def split_range(count = nil)
    start_date, end_date = range
    ret = []

    if count.nil?
      while (tmp_date = start_date + 1.month - 1.day) <= end_date
        ret << [start_date, tmp_date]

        start_date += 1.month
      end
    else
      count.downto(1).each do |idx|
        if idx == 1
          tmp_date = end_date
        else
          tmp_date = start_date + 1.month - 1.day
          if tmp_date >= end_date
            tmp_date = end_date
          end
        end

        ret << [start_date, tmp_date]

        break if tmp_date == end_date
        start_date += 1.month
      end
    end

    ret
  end

  ransacker :sub_company, formatter: ->(qid) {
    # ids = User.search_in_all_translated(search).map(&:id)
    # ids = ids.any? ? ids : nil
    sub_company = SubCompany.find(qid)
    sub_company.customers.select(:id).flat_map{|ec| ec.projects.pluck(:id)}
  } do |parent|
      parent.table[:id]
  end

  def display_name
    [nest_index, name].join('、')
  end

  def engineering_salary_tables
    salary_tables
  end
end
