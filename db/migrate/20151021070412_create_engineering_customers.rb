class CreateEngineeringCustomers < ActiveRecord::Migration
  def change
    create_table :engineering_customers do |t|
      t.text :name
      t.text :telephone
      t.text :identity_card
      t.text :bank_account
      t.text :bank_name, default: '建设银行'
      t.text :bank_opening_place
      t.text :remark

      t.timestamps null: false
    end
  end
end
