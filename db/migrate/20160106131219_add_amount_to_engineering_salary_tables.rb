class AddAmountToEngineeringSalaryTables < ActiveRecord::Migration
  def change
    add_column :engineering_salary_tables, :amount, :decimal, precision: 8, scale: 2
  end
end
