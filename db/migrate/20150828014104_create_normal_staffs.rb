class CreateNormalStaffs < ActiveRecord::Migration
  def change
    create_table :normal_staffs do |t|
      t.text :nest_id,                              index: true
      t.text :name,                                 index: true
      t.text :company_name,                         index: true
      t.text :account,                              index: true
      t.text :account_bank,                         index: true
      t.text :identity_card,                        index: true
      t.date :birth,                                index: true
      t.integer :age,                               index: true
      t.integer :gender,                            index: true, default: 0
      t.text :nation,                               index: true
      t.text :grade,                                index: true
      t.text :address,                              index: true
      t.text :telephone,                            index: true
      t.date :social_insurance_start_date,          index: true
      t.date :current_social_insurance_start_date,  index: true
      t.date :current_medical_insurance_start_date, index: true
      t.decimal :social_insurance_base,             index: true, precision: 8, scale: 2
      t.decimal :medical_insurance_base,            index: true, precision: 8, scale: 2
      t.boolean :has_social_insurance,              index: true
      t.boolean :has_medical_insurance,             index: true
      t.boolean :in_service,                        index: true
      t.boolean :in_release,                        index: true
      t.decimal :house_accumulation_base,           index: true, precision: 8, scale: 2
      t.date :arrive_current_company_at,            index: true
      t.date :contract_start_date,                  index: true
      t.date :contract_end_date,                    index: true
      t.text :social_insurance_serial,              index: true
      t.text :medical_insurance_serial,             index: true
      t.text :medical_insurance_card,               index: true
      t.date :backup_date,                          index: true
      t.text :backup_place,                         index: true
      t.text :work_place,                           index: true
      t.text :work_type,                            index: true
      t.text :remark,                               index: true

      t.timestamps null: false
    end
  end
end
