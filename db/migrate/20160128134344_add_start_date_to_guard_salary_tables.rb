class AddStartDateToGuardSalaryTables < ActiveRecord::Migration
  def change
    add_column :guard_salary_tables, :start_date, :date
    add_index :guard_salary_tables, :start_date
  end
end
