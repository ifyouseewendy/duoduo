class CreateEngineeringCorps < ActiveRecord::Migration
  def change
    create_table :engineering_corps do |t|
      t.text :name
      t.date :contract_start_date
      t.date :contract_end_date

      t.timestamps null: false
    end
  end
end
