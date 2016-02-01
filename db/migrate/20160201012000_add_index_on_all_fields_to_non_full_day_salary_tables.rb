class AddIndexOnAllFieldsToNonFullDaySalaryTables < ActiveRecord::Migration
  def change
    add_index :non_full_day_salary_tables, :name
    add_index :non_full_day_salary_tables, :remark
    add_index :non_full_day_salary_tables, :created_at
    add_index :non_full_day_salary_tables, :updated_at
    add_index :non_full_day_salary_tables, :status
  end
end
