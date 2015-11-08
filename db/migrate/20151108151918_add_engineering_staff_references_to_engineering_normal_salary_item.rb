class AddEngineeringStaffReferencesToEngineeringNormalSalaryItem < ActiveRecord::Migration
  def change
    add_reference :engineering_normal_salary_items, :engineering_staff, index: true, foreign_key: true
  end
end
