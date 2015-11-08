class CreateEngineeringNormalSalaryItems < ActiveRecord::Migration
  def change
    create_table :engineering_normal_salary_items do |t|
      t.text :name
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.decimal :social_insurance, precision: 8, scale: 2
      t.decimal :medical_insurance, precision: 8, scale: 2
      t.decimal :total_insurance, precision: 8, scale: 2
      t.decimal :salary_in_fact, precision: 8, scale: 2
      t.text :remark

      t.timestamps null: false
    end
  end
end
