class AddEngineeringSalaryTableReferencesToEngineeringNormalSalaryItems < ActiveRecord::Migration
  def change
    add_reference\
      :engineering_normal_salary_items,
      :engineering_salary_table,
      index: {name: 'idx_engineering_normal_salary_items_of_table'},
      foreign_key: true
  end
end
