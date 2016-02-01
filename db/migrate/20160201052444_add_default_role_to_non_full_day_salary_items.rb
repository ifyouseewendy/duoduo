class AddDefaultRoleToNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    change_column_default :non_full_day_salary_items, :role, 0
  end
end
