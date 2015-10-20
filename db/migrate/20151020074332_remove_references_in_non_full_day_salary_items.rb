class RemoveReferencesInNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    remove_reference(:non_full_day_salary_items, :salary_table, index: true)
  end
end
