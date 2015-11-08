class AddEngineeringStaffReferencesToEngineeringNormalWithTaxSalaryItem < ActiveRecord::Migration
  def change
    add_reference\
      :engineering_normal_with_tax_salary_items,
      :engineering_staff,\
      index: {name: 'idx_engineering_normal_with_tax_salary_items_of_staff'},
      foreign_key: true
  end
end
