class RemoveColumnNameFromEngineeringNormalSalaryItems < ActiveRecord::Migration
  def change
    remove_column :engineering_normal_salary_items, :name
  end
end
