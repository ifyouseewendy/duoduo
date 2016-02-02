class CreateNewGuardSalaryItems < ActiveRecord::Migration
  def up
    create_table :guard_salary_items do |t|
      t.integer :nest_index, default: 0
      t.text :station
      t.text :staff_account
      t.text :staff_name
      t.decimal :income, precision: 12, scale: 2, default: 0
      t.decimal :salary_base, precision: 12, scale: 2, default: 0
      t.decimal :festival, precision: 12, scale: 2, default: 0
      t.decimal :overtime, precision: 12, scale: 2, default: 0
      t.decimal :exam, precision: 12, scale: 2, default: 0
      t.decimal :duty, precision: 12, scale: 2, default: 0
      t.decimal :salary_deserve, precision: 12, scale: 2, default: 0
      t.decimal :dress_deduct, precision: 12, scale: 2, default: 0
      t.decimal :physical_exam_deduct, precision: 12, scale: 2, default: 0
      t.decimal :pre_deduct, precision: 12, scale: 2, default: 0
      t.decimal :total_deduct, precision: 12, scale: 2, default: 0
      t.decimal :salary_in_fact, precision: 12, scale: 2, default: 0
      t.decimal :accident_insurance, precision: 12, scale: 2, default: 0
      t.decimal :total_sum, precision: 12, scale: 2, default: 0
      t.decimal :balance, precision: 12, scale: 2, default: 0
      t.text :remark
      t.integer :role, default: 0
      t.references :normal_staff
      t.references :guard_salary_table

      t.timestamps
    end
  end

  def down
    drop_table :guard_salary_items
  end
end
