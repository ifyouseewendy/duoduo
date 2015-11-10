class CreateEngineeringBigTableSalaryTableReferences < ActiveRecord::Migration
  def change
    create_table :engineering_big_table_salary_table_references do |t|
      t.text :url

      t.timestamps null: false
    end
  end
end
