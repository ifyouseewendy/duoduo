class AddCreatedAtIndexToEngineeringNormalSalaryItems < ActiveRecord::Migration
  def change
    add_index :engineering_normal_salary_items, :created_at
  end
end
