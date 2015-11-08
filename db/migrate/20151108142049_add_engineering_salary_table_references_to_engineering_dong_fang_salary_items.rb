class AddEngineeringSalaryTableReferencesToEngineeringDongFangSalaryItems < ActiveRecord::Migration
  def change
    add_reference\
      :engineering_dong_fang_salary_items,
      :engineering_salary_table,
      index: {name: 'idx_engineering_dong_fang_salary_items_of_table'},
      foreign_key: true
  end
end
