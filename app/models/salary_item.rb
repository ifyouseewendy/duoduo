class SalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:staff_name)].compact.join(' - ') },
    }

  belongs_to :salary_table
  belongs_to :normal_staff

  enum role: ['normal', 'transfer']

  # Two entrances with callbacks implemented
  #
  #   + SalaryItem.create_by
  #   + SalaryItem#update_by

  # person/company insurance, and additional fees
  before_create :auto_init_fields, unless: -> { @skip_callbacks == true }

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
        [:staff_name, :salary_deserve, :identity_card]
      else
        names = column_names.map(&:to_sym)

        # Fields added by later migration
        polyfill = [:total_sum_with_admin_amount]
        names -= polyfill
        idx = names.index(:total_sum) + 1
        names.insert(idx, *polyfill)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(normal_staff_id salary_table_id) if without_foreign_keys

        names
      end
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def create_by(salary_table:, salary:, name:, identity_card: nil)
      staff = find_staff(salary_table: salary_table, name: name, identity_card: identity_card)
      raise "员工已录入工资条，姓名：#{staff.name}。为避免重复录入，请直接修改现有条目" if salary_table.salary_items.where(normal_staff_id: staff.id).count > 0

      item = self.new(normal_staff: staff, salary_deserve: salary, salary_table: salary_table)
      item.auto_revise!
      item
    end

    # Find by identity_card, if identity_card presents. And staff name should match.
    #
    #   find_staff(salary_table: salary_table, name: name)
    #   find_staff(salary_table: salary_table, name: name, identity_card: identity_card)
    def find_staff(salary_table:, name:, identity_card: nil)
      staffs = salary_table.normal_corporation.normal_staffs

      if identity_card.present?
        staff = staffs.where(identity_card: identity_card).first
        raise "没有找到员工，身份证号：#{identity_card}" if staff.nil?
        raise "员工姓名与身份证号不相符，姓名：#{name}，身份证号：#{identity_card}" if name != staff.name && name.present?
      else
        raise "找到多个员工，重复姓名：#{name}，请附加一列身份证号" if staffs.where(name: name).count > 1

        staff = staffs.where(name: name).first
        raise "没有找到员工，姓名：#{name}" if staff.nil?
      end

      staff
    end

    def batch_form_fields
      fields = whole_columns - \
        [
          :nest_index,
          :staff_account,
          :staff_name,
          :total_personal,
          :salary_in_fact,
          :total_company,
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
        :staff_account,
        :staff_name,
        :salary_deserve,
        :annual_reward,

        # 吉易账户
        :pension_personal,
        :pension_margin_personal,
        :unemployment_personal,
        :unemployment_margin_personal,
        :medical_personal,
        :medical_margin_personal,
        :house_accumulation_personal,
        :big_amount_personal,
        :income_tax,
        :physical_exam_addition,
        :other_personal,

        # 喆琦账户
        :deduct_addition,
        :medical_scan_addition,
        :salary_card_addition,
        :salary_deduct_addition,
        :other_deduct_addition,

        # 个人缴费
        :total_personal,

        # 实发工资
        :salary_in_fact,

        # 单位缴费
        :pension_company,
        :pension_margin_company,
        :unemployment_company,
        :unemployment_margin_company,
        :medical_company,
        :medical_margin_company,
        :injury_company,
        :injury_margin_company,
        :birth_company,
        :birth_margin_company,
        :house_accumulation_company,
        :accident_company,
        :other_company,

        :total_company,

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

    # Use labor_contract data to auto fill
    def insurance_fields
      [
        :pension_personal,
        :unemployment_personal,
        :medical_personal,
        :house_accumulation_personal,

        :pension_company,
        :unemployment_company,
        :medical_company,
        :injury_company,
        :birth_company,
        :house_accumulation_company
      ]
    end

    # To calculate total_personal
    def person_deduct_fields
      [
        # 吉易账户
        :pension_personal,
        :pension_margin_personal,
        :unemployment_personal,
        :unemployment_margin_personal,
        :medical_personal,
        :medical_margin_personal,
        :house_accumulation_personal,
        :big_amount_personal,
        :income_tax,
        :physical_exam_addition,
        :other_personal,

        # 喆琦账户
        :deduct_addition,
        :medical_scan_addition,
        :salary_card_addition,
        :salary_deduct_addition,
        :other_deduct_addition,
      ]
    end

    # To calculate total_company
    def company_deduct_fields
      [
        # 单位缴费
        :pension_company,
        :pension_margin_company,
        :unemployment_company,
        :unemployment_margin_company,
        :medical_company,
        :medical_margin_company,
        :injury_company,
        :injury_margin_company,
        :birth_company,
        :birth_margin_company,
        :house_accumulation_company,
        :accident_company,
        :other_company,
      ]
    end

    def manipulate_insurance_fund_fields
      company_deduct_fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def income_tax_fields
      [
        :pension_personal,
        :pension_margin_personal,
        :unemployment_personal,
        :unemployment_margin_personal,
        :medical_personal,
        :medical_margin_personal,
        :house_accumulation_personal,
      ]
    end

    def sum_fields
      whole_columns - [:nest_index, :staff_account, :staff_name, :remark] + [:total_sum]
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

  def auto_revise!
    # Insurance Fund
    set_insurance_fund

    # Additional Fee
    set_additional_fee

    # Income Tax
    set_income_tax

    # Total
    set_total_personal
    set_salary_in_fact
    set_total_company
    set_total_sum

    # Admin Amount
    set_admin_amount
    set_total_sum_with_admin_amount

    self.save!
  end

  def update_by(attributes)
    self.salary_deserve = attributes[:salary_deserve] if attributes.has_key?(:salary_deserve)
    self.annual_reward = attributes[:annual_reward] if attributes.has_key?(:annual_reward)

    if self.changed?
      set_insurance_fund
      set_additional_fee
      set_income_tax
    end

    attributes.each{|k,v| self.send("#{k}=", v)}

    set_total_personal
    set_salary_in_fact
    set_total_company
    set_total_sum

    self.admin_amount = attributes[:admin_amount] if attributes.has_key?(:admin_amount)

    if self.changed & ['admin_amount', 'other_amount']
      set_total_sum_with_admin_amount
    end

    self.save!
  end

  def auto_init_fields
    return if self.transfer?

    set_name_and_account
    set_insurance_fund
    set_additional_fee
    set_nest_index
  end

  def revise_fields
    # income_tax
    if (self.changed & ['income_tax']).present?
    else
      fields = self.class.income_tax_fields.map(&:to_s) + ['salary_deserve', 'annual_reward']
      if (self.changed & fields).present?
        set_income_tax
      end
    end

    # total_personal
    if (self.changed & self.class.person_deduct_fields.map(&:to_s)).present?
      set_total_personal
    end

    # salary_in_fact
    if (self.changed & ['salary_deserve', 'annual_reward', 'total_personal']).present?
      set_salary_in_fact
    end

    # total_company
    if (self.changed & self.class.company_deduct_fields.map(&:to_s)).present?
      set_total_company
    end

    # total_sum
    if (self.changed & ['salary_deserve', 'annual_reward', 'total_company']).present?
      set_total_sum
    end

    # admin_amount
    unless (self.changed & ['admin_amount']).present?
      if (self.changed & ['total_sum']).present?
        set_admin_amount
      end
    end

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

  def init_addition_fee
    {
      big_amount_personal: 96,
      medical_scan_addition: 10,
      salary_card_addition: 10
    }
  end

  def set_name_and_account
    self.staff_name = self.normal_staff.name
    self.staff_account = self.normal_staff.account
  end

  def set_insurance_fund
    normal_staff.insurance_fund.each{|k,v| self.send("#{k}=", v.to_f.round(2))}
  end

  def set_additional_fee
    init_addition_fee.each{|k,v| self.send("#{k}=", v)}
  end

  def set_nest_index
    if self.role.to_sym == :normal
      self.nest_index = self.salary_table.available_nest_index
    end
  end

  def set_income_tax
    fields = self.class.income_tax_fields
    deduct = fields.map{|df| self.send(df).to_f}.sum.round(2)
    salary = salary_deserve.to_f - deduct

    self.income_tax = IndividualIncomeTax.calculate(salary: salary, bonus: annual_reward).round(2)
  end

  def set_total_personal
    self.total_personal = self.class.person_deduct_fields.map{|field| self.send(field).to_f}.sum.round(2)
  end

  def set_salary_in_fact
    self.salary_in_fact = (self.salary_deserve.to_f + self.annual_reward.to_f - self.total_personal.to_f).round(2)
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
        ( [salary_deserve, annual_reward].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_b? # 比例（应发+单位缴费）
        ( [salary_deserve, annual_reward, total_company].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_c? # 比例（劳务费合计） (total_company + admin_amount) * rate = admin_amount
        sum = [salary_deserve, annual_reward, total_company].map(&:to_f).sum
        ( sum * rate / (1-rate.to_f) ).round(2)
      elsif corporation.by_rate_d? # 比例（应发+意外险）
        ( [salary_deserve, annual_reward, accident_company].map(&:to_f).sum*rate ).round(2)
      elsif corporation.by_rate_e? # 比例（应发+意外险+工伤+管理费+其他）
        sum = [salary_deserve, annual_reward, accident_company, injury_company, other_company].map(&:to_f).sum
        ( sum * rate / (1-rate.to_f) ).round(2)
      else
        0
      end
  end

  def set_total_sum
    self.total_sum = [salary_deserve, annual_reward, total_company].map(&:to_f).sum.round(2)
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

end
