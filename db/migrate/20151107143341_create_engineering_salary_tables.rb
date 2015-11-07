class CreateEngineeringSalaryTables < ActiveRecord::Migration
  def change
    create_table :engineering_salary_tables do |t|
      t.text :name
      t.text :type
      t.text :remark

      t.timestamps null: false
    end
  end
end
