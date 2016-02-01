class AddIndexOnNestIndexAndRoleToNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    add_index :non_full_day_salary_items, [:nest_index, :role]
  end
end
