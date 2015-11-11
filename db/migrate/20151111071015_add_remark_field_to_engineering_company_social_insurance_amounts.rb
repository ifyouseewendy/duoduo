class AddRemarkFieldToEngineeringCompanySocialInsuranceAmounts < ActiveRecord::Migration
  def change
    add_column :engineering_company_social_insurance_amounts, :remark, :text
  end
end
