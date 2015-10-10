class CreateLaborContracts < ActiveRecord::Migration
  def change
    create_table :labor_contracts do |t|
      t.integer :contract_type
      t.boolean :in_contract
      t.date :contract_start_date
      t.date :contract_end_date
      t.date :arrive_current_company_at
      t.boolean :has_social_insurance
      t.boolean :has_medical_insurance
      t.date :current_social_insurance_start_date
      t.date :current_medical_insurance_start_date
      t.decimal :social_insurance_base, precision: 8, scale: 2
      t.decimal :medical_insurance_base, precision: 8, scale: 2
      t.decimal :house_accumulation_base, precision: 8, scale: 2
      t.text :social_insurance_serial
      t.text :medical_insurance_serial
      t.text :medical_insurance_card
      t.date :backup_date
      t.text :backup_place
      t.text :work_place
      t.text :work_type
      t.date :release_date
      t.date :social_insurance_release_date
      t.date :medical_insurance_release_date
      t.text :remark
      t.references :sub_company, index: true, foreign_key: true
      t.references :normal_corporation, index: true, foreign_key: true
      t.references :normal_staff, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
