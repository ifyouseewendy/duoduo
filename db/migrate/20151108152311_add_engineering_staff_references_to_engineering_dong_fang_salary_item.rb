class AddEngineeringStaffReferencesToEngineeringDongFangSalaryItem < ActiveRecord::Migration
  def change
    add_reference\
      :engineering_dong_fang_salary_items,
      :engineering_staff,
      index: {name: 'idx_engineering_dong_fang_salary_items_of_staff'},
      foreign_key: true
  end
end
