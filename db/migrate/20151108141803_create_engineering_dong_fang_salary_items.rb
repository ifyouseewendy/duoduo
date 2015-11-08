class CreateEngineeringDongFangSalaryItems < ActiveRecord::Migration
  def change
    create_table :engineering_dong_fang_salary_items do |t|
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.text :remark

      t.timestamps null: false
    end
  end
end
