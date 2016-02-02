class AddFieldsToGuardSalaryItems < ActiveRecord::Migration
  def change
    add_column :guard_salary_items, :staff_name, :text
    add_column :guard_salary_items, :staff_account, :text
    add_column :guard_salary_items, :station, :text
    add_column :guard_salary_items, :salary_base, :decimal, precision: 12, scale: 2
    add_column :guard_salary_items, :exam, :decimal, precision: 12, scale: 2
    add_column :guard_salary_items, :duty, :decimal, precision: 12, scale: 2
    add_column :guard_salary_items, :total_sum, :decimal, precision: 12, scale: 2
    add_column :guard_salary_items, :role, :integer, default: 0

    remove_column :guard_salary_items, :salary_deserve_total
    remove_column :guard_salary_items, :dress_return
    remove_column :guard_salary_items, :work_exam_deduct
    remove_column :guard_salary_items, :total
  end
end
