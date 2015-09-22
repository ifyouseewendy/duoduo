class CreateSalaryTables < ActiveRecord::Migration
  def change
    create_table :salary_tables do |t|
      t.text :name, index: true
      t.text :remark

      t.timestamps null: false
    end
  end
end
