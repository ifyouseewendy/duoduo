class AddFieldsToNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_items, :nest_index, :integer
    add_column :non_full_day_salary_items, :department, :text
    add_column :non_full_day_salary_items, :station, :text
    add_column :non_full_day_salary_items, :exam, :decimal, precision: 12, scale: 2
    add_column :non_full_day_salary_items, :work_insurance, :decimal, precision: 12, scale: 2
    add_column :non_full_day_salary_items, :other_amount, :decimal, precision: 12, scale: 2

    add_index :non_full_day_salary_items, :nest_index
    add_index :non_full_day_salary_items, :department
    add_index :non_full_day_salary_items, :station
    add_index :non_full_day_salary_items, :exam
    add_index :non_full_day_salary_items, :work_insurance
    add_index :non_full_day_salary_items, :other_amount
  end
end
