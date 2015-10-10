class RemoveColumnsFromNormalStaffs < ActiveRecord::Migration
  def change
    remove_columns :normal_staffs, \
      :company_name,
      :current_social_insurance_start_date,
      :current_medical_insurance_start_date,
      :social_insurance_base,
      :medical_insurance_base,
      :has_social_insurance,
      :has_medical_insurance,
      :in_contract,
      :house_accumulation_base,
      :arrive_current_company_at,
      :contract_start_date,
      :contract_end_date,
      :social_insurance_serial,
      :medical_insurance_serial,
      :medical_insurance_card,
      :backup_date,
      :backup_place,
      :work_place,
      :work_type
  end
end
