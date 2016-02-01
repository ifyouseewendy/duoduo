class RemoveTotalFromNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    remove_index :non_full_day_salary_items, :total
    remove_column :non_full_day_salary_items, :total
  end
end
