class AddCreatedAtIndexToEngineeringNormalWithTaxSalaryItems < ActiveRecord::Migration
  def change
    add_index :engineering_normal_with_tax_salary_items, :created_at
  end
end
