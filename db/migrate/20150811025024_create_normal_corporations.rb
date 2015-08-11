class CreateNormalCorporations < ActiveRecord::Migration
  def change
    create_table :normal_corporations do |t|
      t.text    :name,                 index: true
      t.text    :license,              index: true
      t.text    :taxpayer_serial,      index: true
      t.text    :organization_serial,  index: true
      t.text    :corporate_name,       index: true
      t.text    :address,              index: true
      t.text    :account,              index: true
      t.text    :account_bank,         index: true
      t.text    :contact,              index: true
      t.text    :telephone,            index: true
      t.date    :contract_due_time,    index: true
      t.money   :contract_amount,      index: true
      t.integer :admin_charge_type,    index: true
      t.decimal :admin_charge_amount,  index: true, precision: 8, scale: 2
      t.date    :expense_date,         index: true
      t.integer :stuff_count,          index: true
      t.integer :insurance_count,      index: true
      t.text    :remark
      t.text    :jiyi_company_name,    index: true

      t.timestamps null: false
    end
  end
end


