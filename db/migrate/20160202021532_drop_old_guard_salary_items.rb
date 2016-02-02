class DropOldGuardSalaryItems < ActiveRecord::Migration
  def change
    drop_table :guard_salary_items
  end
end
