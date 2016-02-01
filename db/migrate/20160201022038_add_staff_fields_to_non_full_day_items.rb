class AddStaffFieldsToNonFullDayItems < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_items, :role, :integer
    add_column :non_full_day_salary_items, :staff_name, :text
    add_column :non_full_day_salary_items, :staff_account, :text

    add_index :non_full_day_salary_items, :role
    add_index :non_full_day_salary_items, :staff_name
    add_index :non_full_day_salary_items, :staff_account
  end
end
