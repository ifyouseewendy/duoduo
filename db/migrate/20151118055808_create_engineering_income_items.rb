class CreateEngineeringIncomeItems < ActiveRecord::Migration
  def change
    create_table :engineering_income_items do |t|
      t.datetime :date
      t.decimal :amount, precision: 8, scale: 2
      t.text :remark

      t.timestamps null: false
    end
  end
end
