class RemoveFieldsFromNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    remove_column :non_full_day_salary_items, :month
  end
end
