class AddFieldsToNonFullDaySalaryTables < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_tables, :lai_table, :text
    add_column :non_full_day_salary_tables, :daka_table, :text
    add_column :non_full_day_salary_tables, :status, :integer
  end
end
