class EngineeringProject < ActiveRecord::Base
  belongs_to :engineering_customer
  belongs_to :engineering_corp
  has_and_belongs_to_many :engineering_staffs

  has_many :engineering_salary_tables, dependent: :destroy

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy

  before_save :revise_fields

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_customer_id engineering_corp_id) if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
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
  end

  def revise_fields
    if (changed && [:project_start_date, :project_end_date]).present?
      self.project_range = -> {
        month, day = calc_range

        range = ''
        range += "#{month} 个月 " if month > 0
        range += "#{day} 天" if day > 0
        range
      }.call
    end

    if (changed && [:project_amount, :admin_amount]).present?
      self.total_amount = project_amount + admin_amount
    end
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

  # Precondition:
  #   amount - should be an Integer
  def gennerate_random_salary(amount:, count:)
    raise "来款金额需为整数" if amount != amount.to_i

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

    # TODO
    #   Need to ensure no spliting range is right
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
end
