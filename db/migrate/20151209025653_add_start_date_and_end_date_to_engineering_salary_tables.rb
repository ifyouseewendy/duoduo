class AddStartDateAndEndDateToEngineeringSalaryTables < ActiveRecord::Migration
  def change
    add_column :engineering_salary_tables, :start_date, :date
    add_column :engineering_salary_tables, :end_date, :date
  end
end
