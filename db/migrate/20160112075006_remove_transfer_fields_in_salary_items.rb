class RemoveTransferFieldsInSalaryItems < ActiveRecord::Migration
  def change
    remove_columns :salary_items, \
      :social_insurance_to_salary_deserve,
      :medical_insurance_to_salary_deserve,
      :house_accumulation_to_salary_deserve,
      :social_insurance_to_pre_deduct,
      :medical_insurance_to_pre_deduct,
      :house_accumulation_to_pre_deduct,
      :transfer_fund_to_person,
      :transfer_fund_to_account
  end
end
