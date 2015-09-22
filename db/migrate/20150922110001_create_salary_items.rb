class CreateSalaryItems < ActiveRecord::Migration
  def change
    create_table :salary_items do |t|
      t.decimal :working_hour, precision: 8, scale: 2
      t.decimal :working_wage, precision: 8, scale: 2
      t.decimal :working_overtime, precision: 8, scale: 2
      t.decimal :working_reward, precision: 8, scale: 2
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.decimal :annual_reward, precision: 8, scale: 2
      t.decimal :pension_personal, precision: 8, scale: 2
      t.decimal :pension_margin_personal, precision: 8, scale: 2
      t.decimal :unemployment_personal, precision: 8, scale: 2
      t.decimal :unemployment_margin_personal, precision: 8, scale: 2
      t.decimal :medical_personal, precision: 8, scale: 2
      t.decimal :medical_margin_personal, precision: 8, scale: 2
      t.decimal :house_accumulation_personal, precision: 8, scale: 2
      t.decimal :big_amount_personal, precision: 8, scale: 2
      t.decimal :income_tax, precision: 8, scale: 2
      t.decimal :salary_card_addition, precision: 8, scale: 2
      t.decimal :medical_scan_addition, precision: 8, scale: 2
      t.decimal :salary_pre_deduct_addition, precision: 8, scale: 2
      t.decimal :insurance_pre_deduct_addition, precision: 8, scale: 2
      t.decimal :physical_exam_addition, precision: 8, scale: 2
      t.decimal :total_personal, precision: 8, scale: 2
      t.decimal :salary_in_fact, precision: 8, scale: 2
      t.decimal :pension_company, precision: 8, scale: 2
      t.decimal :pension_margin_company, precision: 8, scale: 2
      t.decimal :unemployment_company, precision: 8, scale: 2
      t.decimal :unemployment_margin_company, precision: 8, scale: 2
      t.decimal :medical_company, precision: 8, scale: 2
      t.decimal :medical_margin_company, precision: 8, scale: 2
      t.decimal :injury_company, precision: 8, scale: 2
      t.decimal :injury_margin_company, precision: 8, scale: 2
      t.decimal :birth_company, precision: 8, scale: 2
      t.decimal :birth_margin_company, precision: 8, scale: 2
      t.decimal :accident_company, precision: 8, scale: 2
      t.decimal :house_accumulation_company, precision: 8, scale: 2
      t.decimal :total_company, precision: 8, scale: 2
      t.decimal :social_insurance_to_salary_deserve, precision: 8, scale: 2
      t.decimal :social_insurance_to_pre_deduct, precision: 8, scale: 2
      t.decimal :medical_insurance_to_salary_deserve, precision: 8, scale: 2
      t.decimal :medical_insurance_to_pre_deduct, precision: 8, scale: 2
      t.decimal :house_accumulation_to_salary_deserve, precision: 8, scale: 2
      t.decimal :house_accumulation_to_pre_deduct, precision: 8, scale: 2
      t.decimal :admin_amount, precision: 8, scale: 2
      t.decimal :total_sum, precision: 8, scale: 2
      t.text    :remark

      t.timestamps null: false
    end
  end
end
