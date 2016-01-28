class AddStartDateToNonFullDaySalaryTables < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_tables, :start_date, :date
    add_index :non_full_day_salary_tables, :start_date
  end
end
