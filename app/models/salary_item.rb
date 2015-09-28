class SalaryItem < ActiveRecord::Base
  belongs_to :salary_table
  belongs_to :normal_staff

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_staff_id salary_table_id) if without_foreign_keys

      names
    end

    def create_by(name:, salary:, salary_table:)
      staff = salary_table.normal_corporation.normal_staffs.where(name: name).first
      raise "No staff found for name: #{name}" if staff.nil?

      item = self.new( {normal_staff: staff, salary_deserve: salary}.merge( staff.insurance_fund ) )
      item.revise_total!
      item
    end
  end

  def revise_total!
    set_total_personal
    set_salary_in_fact
    set_total_company
    set_admin_amount
    set_total_sum
    set_total_sum_with_admin_amount
    self.save!
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

end
