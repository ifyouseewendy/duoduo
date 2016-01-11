class AddIndexInLaborContracts < ActiveRecord::Migration
  def change
    add_index :labor_contracts, :contract_type
    add_index :labor_contracts, :in_contract
    add_index :labor_contracts, :contract_start_date
    add_index :labor_contracts, :contract_end_date
    add_index :labor_contracts, :arrive_current_company_at
    add_index :labor_contracts, :has_social_insurance
    add_index :labor_contracts, :has_medical_insurance
    add_index :labor_contracts, :has_accident_insurance
    add_index :labor_contracts, :current_social_insurance_start_date
    add_index :labor_contracts, :current_medical_insurance_start_date
    add_index :labor_contracts, :social_insurance_base
    add_index :labor_contracts, :medical_insurance_base
    add_index :labor_contracts, :house_accumulation_base
    add_index :labor_contracts, :social_insurance_serial
    add_index :labor_contracts, :medical_insurance_serial
    add_index :labor_contracts, :medical_insurance_card
    add_index :labor_contracts, :backup_date
    add_index :labor_contracts, :backup_place
    add_index :labor_contracts, :work_type
    add_index :labor_contracts, :work_place
    add_index :labor_contracts, :release_date
    add_index :labor_contracts, :social_insurance_release_date
    add_index :labor_contracts, :medical_insurance_release_date
  end
end
