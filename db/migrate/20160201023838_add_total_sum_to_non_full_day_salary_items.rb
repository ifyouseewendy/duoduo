class AddTotalSumToNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_items, :total_sum, :decimal, precision: 12, scale: 2
    add_column :non_full_day_salary_items, :total_sum_with_admin_amount, :decimal, precision: 12, scale: 2

    add_index :non_full_day_salary_items, :total_sum
    add_index :non_full_day_salary_items, :total_sum_with_admin_amount
  end
end
