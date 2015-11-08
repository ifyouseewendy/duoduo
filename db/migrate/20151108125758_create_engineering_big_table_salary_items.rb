class CreateEngineeringBigTableSalaryItems < ActiveRecord::Migration
  def change
    create_table :engineering_big_table_salary_items do |t|
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.decimal :pension_personal, precision: 8, scale: 2
      t.decimal :unemployment_personal, precision: 8, scale: 2
      t.decimal :medical_personal, precision: 8, scale: 2
      t.decimal :total_personal, precision: 8, scale: 2
      t.decimal :salary_in_fact, precision: 8, scale: 2
      t.decimal :pension_company, precision: 8, scale: 2
      t.decimal :unemployment_company, precision: 8, scale: 2
      t.decimal :medical_company, precision: 8, scale: 2
      t.decimal :injury_company, precision: 8, scale: 2
      t.decimal :birth_company, precision: 8, scale: 2
      t.decimal :total_company, precision: 8, scale: 2
      t.decimal :total_sum, precision: 8, scale: 2
      t.text :remark

      t.timestamps null: false
    end
  end
end
