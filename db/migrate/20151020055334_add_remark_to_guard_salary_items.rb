class AddRemarkToGuardSalaryItems < ActiveRecord::Migration
  def change
    add_column :guard_salary_items, :remark, :text
  end
end
