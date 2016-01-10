class UpdateFieldsInSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :salary_deduct_addition, :decimal, precision: 8, scale: 2
    add_column :salary_items, :other_deduct_addition, :decimal, precision: 8, scale: 2
    add_column :salary_items, :other_personal, :decimal, precision: 8, scale: 2
  end
end
