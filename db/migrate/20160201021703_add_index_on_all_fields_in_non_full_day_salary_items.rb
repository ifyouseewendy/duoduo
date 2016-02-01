class AddIndexOnAllFieldsInNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    add_index :non_full_day_salary_items, :work_hour
    add_index :non_full_day_salary_items, :work_wage
    add_index :non_full_day_salary_items, :salary_deserve
    add_index :non_full_day_salary_items, :tax
    add_index :non_full_day_salary_items, :other
    add_index :non_full_day_salary_items, :salary_in_fact
    add_index :non_full_day_salary_items, :accident_insurance
    add_index :non_full_day_salary_items, :admin_amount
    add_index :non_full_day_salary_items, :total
    add_index :non_full_day_salary_items, :remark
    add_index :non_full_day_salary_items, :created_at
    add_index :non_full_day_salary_items, :updated_at
  end
end
