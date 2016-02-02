class AddIndexOnAllFieldsToGuardSalaryItems < ActiveRecord::Migration
  def change
    add_index :guard_salary_items, :nest_index
    add_index :guard_salary_items, :station
    add_index :guard_salary_items, :staff_account
    add_index :guard_salary_items, :staff_name
    add_index :guard_salary_items, :income
    add_index :guard_salary_items, :salary_base
    add_index :guard_salary_items, :festival
    add_index :guard_salary_items, :overtime
    add_index :guard_salary_items, :exam
    add_index :guard_salary_items, :duty
    add_index :guard_salary_items, :salary_deserve
    add_index :guard_salary_items, :dress_deduct
    add_index :guard_salary_items, :physical_exam_deduct
    add_index :guard_salary_items, :pre_deduct
    add_index :guard_salary_items, :total_deduct
    add_index :guard_salary_items, :salary_in_fact
    add_index :guard_salary_items, :accident_insurance
    add_index :guard_salary_items, :total_sum
    add_index :guard_salary_items, :balance
    add_index :guard_salary_items, :remark
    add_index :guard_salary_items, :role
    add_index :guard_salary_items, :normal_staff_id
    add_index :guard_salary_items, :guard_salary_table_id
    add_index :guard_salary_items, :created_at
    add_index :guard_salary_items, :updated_at
    add_index :guard_salary_items, [:nest_index, :role]
  end
end
