class SalaryItem < ActiveRecord::Base
  belongs_to :salary_table
  belongs_to :normal_staff

  # Two entrances with callbacks implemented
  #
  #   + SalaryItem.create_by
  #   + SalaryItem#update_by

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

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

    def columns_based_on(view: nil)
      all_fields = \
        [
          :id,
          :staff_identity_card,
          :staff_account,
          :staff_category,
          :staff_company_name,
          :normal_staff_name,
          :salary_table_name
        ] + ordered_columns(without_base_keys: true, without_foreign_keys: true) - [:remark]

      case view.to_s
      when 'archive'
        all_fields
      when 'proof'
        all_fields - [:admin_amount, :total_sum_with_admin_amount]
      when 'card'
        [:staff_account, :normal_staff_name, :salary_in_fact]
      else
        all_fields
      end
    end
  end

  def staff_identity_card
    normal_staff.identity_card rescue ''
  end

  def staff_account
    normal_staff.account
  end

  def staff_company
    normal_staff.normal_corporation
  end

  def staff_company_name
    staff_company.name
  end

  def staff_category
    ''
  end

  def staff_name
    normal_staff.name rescue ''
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

    if self.changed.include?(:admin_amount)
      set_total_sum_with_admin_amount
    end

    self.save!
  end

  def set_insurance_fund
    normal_staff.insurance_fund.each{|k,v| self.send("#{k}=", v)}
  end

  def set_additional_fee
    normal_staff.init_addition_fee.each{|k,v| self.send("#{k}=", v)} if normal_staff.has_no_salary_item?
  end

  def set_income_tax
    self.income_tax = IndividualIncomeTax.calculate(salary: salary_deserve, bonus: annual_reward)
  end

  def set_total_personal
    self.total_personal = [
      pension_personal, pension_margin_personal,
      unemployment_personal, unemployment_margin_personal,
      medical_personal, medical_margin_personal,
      house_accumulation_personal,
      big_amount_personal,
      income_tax,
      salary_card_addition, medical_scan_addition, salary_pre_deduct_addition, insurance_pre_deduct_addition, physical_exam_addition
    ].map(&:to_f).sum
  end

  def set_salary_in_fact
    self.salary_in_fact = salary_deserve - total_personal
  end

  def set_total_company
    self.total_company = [
      pension_company, pension_margin_company,
      unemployment_company, unemployment_margin_company,
      medical_company, medical_margin_company,
      injury_company, injury_margin_company,
      birth_company, birth_margin_company,
      accident_company,
      house_accumulation_company
    ].map(&:to_f).sum
  end

  def set_admin_amount
    self.admin_amount = \
      if corporation.by_rate?
        set_total_sum * corporation.admin_charge_amount
      else
        corporation.admin_charge_amount
      end
  end

  def set_total_sum
    self.total_sum = salary_deserve + total_company
  end

  def set_total_sum_with_admin_amount
    self.total_sum_with_admin_amount = total_sum + admin_amount
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

end
