class CreateEngineeringCompanyMedicalInsuranceAmounts < ActiveRecord::Migration
  def change
    create_table :engineering_company_medical_insurance_amounts do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :amount, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
