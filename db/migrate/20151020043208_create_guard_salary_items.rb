class CreateGuardSalaryItems < ActiveRecord::Migration
  def change
    create_table :guard_salary_items do |t|
      t.decimal :income, precision: 8, scale: 2
      t.decimal :salary_deserve, precision: 8, scale: 2
      t.decimal :festival, precision: 8, scale: 2
      t.decimal :overtime, precision: 8, scale: 2
      t.decimal :dress_return, precision: 8, scale: 2
      t.decimal :salary_deserve_total, precision: 8, scale: 2
      t.decimal :physical_exam_deduct, precision: 8, scale: 2
      t.decimal :dress_deduct, precision: 8, scale: 2
      t.decimal :work_exam_deduct, precision: 8, scale: 2
      t.decimal :other_deduct, precision: 8, scale: 2
      t.decimal :total_deduct, precision: 8, scale: 2
      t.decimal :salary_in_fact, precision: 8, scale: 2
      t.decimal :accident_insurance, precision: 8, scale: 2
      t.decimal :total, precision: 8, scale: 2
      t.decimal :balance, precision: 8, scale: 2
      t.references :normal_staff, index: true, foreign_key: true
      t.references :guard_salary_table, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
