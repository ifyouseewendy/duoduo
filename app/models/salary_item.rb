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

      self.create!( {normal_staff: staff, salary_deserve: salary}.merge( staff.insurance_fund ) )
    end
  end

  def total_personal
    @_total_personal ||= [
      pension_personal, pension_margin_personal,
      unemployment_personal, unemployment_margin_personal,
      medical_personal, medical_margin_personal,
      house_accumulation_personal,
      big_amount_personal,
      income_tax,
      salary_card_addition, medical_scan_addition, salary_pre_deduct_addition, insurance_pre_deduct_addition, physical_exam_addition
    ].map(&:to_f).sum
  end

  def salary_in_fact
    salary_deserve - total_personal
  end

  def total_company
    @_total_company ||= [
      pension_company, pension_margin_company,
      unemployment_company, unemployment_margin_company,
      medical_company, medical_margin_company,
      injury_company, injury_margin_company,
      birth_company, birth_margin_company,
      accident_company,
      house_accumulation_company
    ].map(&:to_f).sum
  end

  def admin_amount
    if corporation.by_rate?
      total_sum * corporation.admin_charge_amount
    else
      corporation.admin_charge_amount
    end
  end

  def corporation
    normal_staff.normal_corporation
  end

  def total_sum
    salary_deserve + total_company
  end

  def total_sum_with_admin_amount
    total_sum + admin_amount
  end
end
