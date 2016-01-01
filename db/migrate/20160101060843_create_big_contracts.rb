class CreateBigContracts < ActiveRecord::Migration
  def change
    create_table :big_contracts do |t|
      t.date :start_date
      t.date :end_date
      t.references :sub_company, index: true, foreign_key: true
      t.references :engineering_corp, index: true, foreign_key: true
      t.text :file

      t.timestamps null: false
    end
  end
end
