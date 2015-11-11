class AddRemarkFieldToEngineeringCompanyMedicalInsuranceAmounts < ActiveRecord::Migration
  def change
    add_column :engineering_company_medical_insurance_amounts, :remark, :text
  end
end
