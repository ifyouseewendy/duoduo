class IndexOnAllFieldsToGuardSalaryTables < ActiveRecord::Migration
  def change
    add_index :guard_salary_tables, :name
    add_index :guard_salary_tables, :created_at
    add_index :guard_salary_tables, :updated_at
    add_index :guard_salary_tables, :status
  end
end
