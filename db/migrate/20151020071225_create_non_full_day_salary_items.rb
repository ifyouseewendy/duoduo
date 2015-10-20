class CreateNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    create_table :non_full_day_salary_items do |t|
      t.text :month
      t.decimal :work_hour, precision: 8, scale: 2
      t.decimal :work_wage, precision: 8, scale: 2
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.decimal :tax, precision: 8, scale: 2
      t.decimal :other, precision: 8, scale: 2
      t.decimal :salary_in_fact, precision: 8, scale: 2
      t.decimal :accident_insurance, precision: 8, scale: 2
      t.decimal :admin_amount, precision: 8, scale: 2
      t.decimal :total, precision: 8, scale: 2
      t.references :salary_table, index: true, foreign_key: true
      t.references :normal_staff, index: true, foreign_key: true
      t.text :remark

      t.timestamps null: false
    end
  end
end
