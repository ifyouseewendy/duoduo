class NonFullDaySalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:staff_name)].compact.join(' - ') },
    }

  belongs_to :non_full_day_salary_table
  belongs_to :normal_staff

  enum role: ['normal', 'transfer']

  before_create :auto_init_fields, unless: -> { @skip_callbacks == true }

  before_save :set_work_wage
  # income_tax, other total fields
  after_save :revise_fields

  # update nest_index on table's other salary_items
  after_destroy :revise_nest_index

  default_scope { order(nest_index: :asc).order(role: :asc) }

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        [:department, :station, :staff_name, :work_hour, :work_wage, :salary_deserve, :work_insurance, :accident_insurance, :other_amount, :identity_card]
      else
        names = column_names.map(&:to_sym)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(normal_staff_id non_full_day_salary_table_id) if without_foreign_keys

        names
      end
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = whole_columns - \
        [
          :nest_index,
          :staff_name,
          :salary_in_fact,
          :total_sum,
          :total_sum_with_admin_amount
        ]

      fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def columns_based_on(view: nil, custom: nil)
      view ||= :whole

      case view.to_s
      when 'proof', 'card', 'whole'
        self.send("#{view}_columns")
      when 'custom'
        custom.to_s.strip.split('-').map(&:to_sym)
      else
        raise "Unsupported view: #{view}"
      end
    end

    def whole_columns
      [
        # 员工信息
        :nest_index,
        :department,
        :station,
        :staff_account,
        :staff_name,
        :work_hour,
        :work_wage,
        :salary_deserve,

        # 吉易账户
        :tax,

        # 实发工资
        :salary_in_fact,

        # 单位缴费
        :work_insurance,
        :accident_insurance,

        # 管理费
        :admin_amount,
        :other_amount,

        # 劳务费合计
        :total_sum_with_admin_amount,

        :remark,
      ]
    end

    def card_columns
      [:nest_index, :staff_account, :staff_name, :salary_in_fact]
    end

    def proof_columns
      whole_columns\
        - [:admin_amount, :other_amount, :total_sum_with_admin_amount, :remark]\
        + [:total_sum, :remark]
    end

    # To calculate total_personal
    def person_deduct_fields
      [
        # 吉易账户
        :tax,
      ]
    end

    # To calculate total_company
    def company_deduct_fields
      [
        # 单位缴费
        :work_insurance,
        :accident_insurance,
      ]
    end

    def manipulate_insurance_fund_fields
      company_deduct_fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def income_tax_fields
      []
    end

    def sum_fields
      whole_columns - [:nest_index, :department, :station, :staff_account, :staff_name, :work_hour, :work_wage, :remark] + [:total_sum]
    end
  end # Class method ends

  def staff_identity_card
  end

  def corporation
    normal_staff.normal_corporation
  end

  def normal_staff_name
    normal_staff.name
  end

  def salary_table_name
    salary_table.name
  end

  def auto_init_fields
    return if self.transfer?

    set_name_and_account
    set_nest_index
  end

  def revise_fields
    # work_wage
    if (self.changed & ['salary_deserve']).present?
      if self.work_wage.to_i.nonzero?
        self.work_hour = (self.salary_deserve.to_f / self.work_wage.to_i).round(1)
      end
    else
      if (self.changed & ['work_wage', 'work_hour']).count == 2
        self.salary_deserve = (self.work_wage.to_f * self.work_hour.to_f).round(1)
      else
        if (self.changed & ['work_wage']).present?
          if self.work_wage.to_i.nonzero?
            self.work_hour = (self.salary_deserve.to_f / self.work_wage.to_i).round(1)
          end
        elsif (self.changed & ['work_hour']).present?
          if self.work_hour.to_i.nonzero?
            self.work_wage = (self.salary_deserve.to_f / self.work_hour.to_i).round(0)
          end
        end
      end
    end

    # income_tax
    if (self.changed & ['tax']).present?
    else
      if (self.changed & ['salary_deserve']).present?
        set_income_tax
      end
    end

    # salary_in_fact
    if (self.changed & ['salary_deserve', 'tax']).present?
      set_salary_in_fact
    end

    # total_sum
    if (self.changed & ['salary_deserve', 'work_insurance', 'accident_insurance']).present?
      set_total_sum
    end

    # admin_amount
    unless (self.changed & ['admin_amount']).present?
      if (self.changed & ['total_sum']).present?
        set_admin_amount
      end
    end

    # total_sum_with_admin_amount
    if (self.changed & ['total_sum', 'admin_amount', 'other_amount']).present?
      set_total_sum_with_admin_amount
    end

    self.update_columns(self.attributes)

    if (self.changed & ['total_sum_with_admin_amount']).present?
      salary_table.validate_amount
    end
  end

  def revise_nest_index
    return if siblings.count > 0

    self.salary_table.salary_items.where("nest_index > ?", self.nest_index).each do |si|
      si.update_column(:nest_index, si.nest_index - 1)
    end
  end

  def transfer_sibling
    salary_table.salary_items.transfer.where(nest_index: self.nest_index).first
  end

  def normal_sibling
    salary_table.salary_items.normal.where(nest_index: self.nest_index).first
  end

  def siblings
    salary_table.salary_items.where(nest_index: self.nest_index).where.not(id: self.id)
  end

  def set_name_and_account
    self.staff_name = self.normal_staff.name
    self.staff_account = self.normal_staff.account
  end

  def set_nest_index
    if self.role.to_sym == :normal
      self.nest_index = self.salary_table.available_nest_index
    end
  end

  def set_income_tax
    self.tax = IndividualIncomeTax.calculate(salary: salary_deserve.to_f, bonus: 0).round(2)
  end

  def set_salary_in_fact
    self.salary_in_fact = (self.salary_deserve.to_f - self.tax.to_f).round(2)
  end

  def set_total_company
    self.total_company = self.class.company_deduct_fields.map{|field| self.send(field).to_f}.sum.round(2)
  end

  def set_admin_amount
    rate = corporation.admin_charge_amount || 0

    self.admin_amount = \
      if corporation.by_count?
        rate
      elsif corporation.by_rate_a? # 比例（应发）
        ( [salary_deserve].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_b? # 比例（应发+单位缴费）
        ( [salary_deserve, work_insurance, accident_insurance].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_c? # 比例（劳务费合计） (total_company + admin_amount) * rate = admin_amount
        sum = [salary_deserve, work_insurance, accident_insurance].map(&:to_f).sum
        ( sum * rate / (1-rate.to_f) ).round(2)
      elsif corporation.by_rate_d? # 比例（应发+意外险）
        ( [salary_deserve, accident_insurance].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_e? # 比例（应发+意外险+工伤+管理费+其他）
        sum = [salary_deserve, accident_insurance, work_insurance].map(&:to_f).sum
        ( sum * rate / (1-rate.to_f) ).round(2)
      else
        0
      end
  end

  def set_total_sum
    self.total_sum = [salary_deserve, work_insurance, accident_insurance].map(&:to_f).sum.round(2)
  end

  def set_total_sum_with_admin_amount
    self.total_sum_with_admin_amount = [total_sum, admin_amount, other_amount].map(&:to_f).sum.round(2)
  end

  def manipulate_personal_fund(options)
    fields = self.class.person_deduct_fields

    staff = NormalStaff.zheqi.first
    staff_name = staff.name
    staff_account = staff.account

    attrs = {
      nest_index: self.nest_index,
      role: 'transfer',
      normal_staff: staff,
      staff_name: staff_name,
      staff_account: staff_account,
      salary_deserve: salary_deserve,
    }

    fields.each do |k|
      attrs[k] = self.send(k)
    end

    admin_before = self.admin_amount

    self.class.transaction do
      # Update self fields to nil
      fields.each{|fi| self.send("#{fi}=", nil)}
      self.salary_deserve = 0
      self.save!
      self.update_attribute(:admin_amount, admin_before) # No change on admin_amount

      # Create new transfer
      self.salary_table.salary_items.create!( attrs.merge({admin_amount: 0}) )
    end
  end

  def manipulate_insurance_fund(options)
    # raise "操作失败<#{self.staff_name}>：无法在转移工资条上再做转移"\
    #   if self.transfer?

    fields = options.select{|k,v| v == 'checked'}.keys.map(&:to_sym)
    raise "非法请求：#{fields.join(',')}"\
      if (fields - self.class.company_deduct_fields).present?

    salary_deserve = fields.map{|f| self.send(f)}.map(&:to_f).sum.round(2)

    transfer_to, other_name, other_account = options.values_at(:transfer_to, :other_name, :other_account)
    case transfer_to.to_sym
    when :self
      staff = self.normal_staff
      staff_name = self.staff_name
      staff_account = self.staff_account
    when :zheqi
      staff = NormalStaff.zheqi.first
      staff_name = staff.name
      staff_account = staff.account
    when :other
      staff = nil
      staff_name = other_name.try(:delete, ' ')
      staff_account = other_account.try(:delete, ' ')
    end

    attrs = {
      nest_index: self.nest_index,
      role: 'transfer',
      normal_staff: staff,
      staff_name: staff_name,
      staff_account: staff_account,
      salary_deserve: salary_deserve,
    }

    fields.each do |k|
      attrs[k] = self.send(k)
    end

    admin_before = self.admin_amount

    self.class.transaction do
      # Update self fields to nil
      fields.each{|fi| self.send("#{fi}=", nil)}
      self.save!

      admin_after = self.admin_amount

      # Create new transfer
      self.salary_table.salary_items.create!( attrs.merge({admin_amount: admin_before-admin_after}) )
    end

  end

  def salary_table
    non_full_day_salary_table
  end

  def set_work_wage
    return if self.normal_staff.nil?

    last_work_wage = self.normal_staff.non_full_day_salary_items.order(created_at: :desc).first.try(:work_wage)
    self.work_wage ||= last_work_wage
  end
end
