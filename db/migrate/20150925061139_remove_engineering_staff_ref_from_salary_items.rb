class RemoveEngineeringStaffRefFromSalaryItems < ActiveRecord::Migration
  def change
    remove_reference :salary_items, :engineering_staff, index: true, foreign_key: true
  end
end
