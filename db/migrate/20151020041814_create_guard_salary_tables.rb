class CreateGuardSalaryTables < ActiveRecord::Migration
  def change
    create_table :guard_salary_tables do |t|
      t.text :name
      t.text :remark
      t.references :normal_corporation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
