class RemoveColumnNameFromEngineeringNormalWithTaxSalaryItems < ActiveRecord::Migration
  def change
    remove_column :engineering_normal_with_tax_salary_items, :name
  end
end
