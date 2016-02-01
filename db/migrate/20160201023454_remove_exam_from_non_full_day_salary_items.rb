class RemoveExamFromNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    remove_index :non_full_day_salary_items, :exam
    remove_column :non_full_day_salary_items, :exam
  end
end
