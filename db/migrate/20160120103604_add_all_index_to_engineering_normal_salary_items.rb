class AddAllIndexToEngineeringNormalSalaryItems < ActiveRecord::Migration
  def change
    add_index :engineering_normal_salary_items, :salary_deserve
    add_index :engineering_normal_salary_items, :social_insurance
    add_index :engineering_normal_salary_items, :medical_insurance
    add_index :engineering_normal_salary_items, :total_insurance
    add_index :engineering_normal_salary_items, :salary_in_fact
    add_index :engineering_normal_salary_items, :remark
  end
end
