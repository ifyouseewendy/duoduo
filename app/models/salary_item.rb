class SalaryItem < ActiveRecord::Base
  belongs_to :salary_table
  belongs_to :normal_staff

  enum role: ['normal', 'transfer']

  # Two entrances with callbacks implemented
  #
  #   + SalaryItem.create_by
  #   + SalaryItem#update_by

  # person/company insurance, and additional fees
  before_create :auto_init_fields

  # income_tax, other total fields
  after_save :revise_fields

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      # Fields added by later migration
      polyfill = [:medical_insurance_to_salary_deserve, :house_accumulation_to_salary_deserve]
      names -= polyfill
      idx = names.index(:social_insurance_to_salary_deserve) + 1
      names.insert(idx, *polyfill)

      polyfill = [:transfer_fund_to_person, :transfer_fund_to_account]
      names -= polyfill
      idx = names.index(:house_accumulation_to_pre_deduct) + 1
      names.insert(idx, *polyfill)

      polyfill = [:total_sum_with_admin_amount]
      names -= polyfill
      idx = names.index(:total_sum) + 1
      names.insert(idx, *polyfill)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_staff_id salary_table_id) if without_foreign_keys

      names
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
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)\
        - [:total_personal, :salary_in_fact, :total_company, :total_sum, :total_sum_with_admin_amount]
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
        :id,
        :staff_account,
        :normal_staff,
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
        :unemployment_company,
        :medical_company,
        :injury_company,
        :birth_company,
        :pension_margin_company,
        :unemployment_margin_company,
        :medical_margin_company,
        :injury_margin_company,
        :birth_margin_company,
        :house_accumulation_company,
        :accident_company,
        :other_company,

        :total_company,

        # 管理费
        :admin_amount,

        # 劳务费合计
        :total_sum_with_admin_amount,

        :remark,
      ]
    end

    def card_columns
      [:staff_account, :normal_staff, :salary_in_fact]
    end

    def proof_columns
      whole_columns\
        - [:admin_amount, :total_sum_with_admin_amount, :remark]\
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
        :unemployment_company,
        :medical_company,
        :injury_company,
        :birth_company,
        :pension_margin_company,
        :unemployment_margin_company,
        :medical_margin_company,
        :injury_margin_company,
        :birth_margin_company,
        :house_accumulation_company,
        :accident_company,
        :other_company,
      ]
    end
  end # Class method ends

  def staff_account
    normal_staff.account
  end

  def staff_name
  end

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

    if self.changed & ['admin_amount']
      set_total_sum_with_admin_amount
    end

    self.save!
  end

  def auto_init_fields
    set_insurance_fund
    set_additional_fee
  end

  def revise_fields
    # income_tax
    if (self.changed & ['income_tax']).present?
    else
      if (self.changed & ['salary_deserve', 'annual_reward']).present?
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
    if (self.changed & ['total_sum']).present?
      set_admin_amount
    end

    if (self.changed & ['admin_amount']).present?
      set_total_sum_with_admin_amount
    end

    self.update_columns(self.attributes)
  end

  def init_addition_fee
    {
      big_amount_personal: 96,
      medical_scan_addition: 10,
      salary_card_addition: 10
    }
  end

  def set_insurance_fund
    normal_staff.insurance_fund.each{|k,v| self.send("#{k}=", v.to_f.round(2))}
  end

  def set_additional_fee
    init_addition_fee.each{|k,v| self.send("#{k}=", v)}
  end

  def set_income_tax
    self.income_tax = IndividualIncomeTax.calculate(salary: salary_deserve, bonus: annual_reward).round(2)
  end

  def set_total_personal
    self.total_personal = self.class.person_deduct_fields.map{|field| self.send(field).to_f}.sum.round(2)
  end

  def set_salary_in_fact
    self.salary_in_fact = (self.salary_deserve - self.total_personal).round(2)
  end

  def set_total_company
    self.total_company = self.class.company_deduct_fields.map{|field| self.send(field).to_f}.sum.round(2)
  end

  def set_admin_amount
    rate = corporation.admin_charge_amount || 0

    self.admin_amount = \
      if corporation.by_rate_on_salary?
        (self.salary_deserve + self.annual_reward)*rate
      elsif corporation.by_rate_on_salary_and_company?
        self.total_sum*rate
      else
        rate
      end
  end

  def set_total_sum
    self.total_sum = (self.salary_deserve + self.total_company).round(2)
  end

  def set_total_sum_with_admin_amount
    self.total_sum_with_admin_amount = total_sum + admin_amount
  end

end
