class RemoveColumnsInSalaryItems < ActiveRecord::Migration
  def change
    remove_columns :salary_items, :salary_pre_deduct_addition, :insurance_pre_deduct_addition
    add_column :salary_items, :deduct_addition, :decimal, precision: 8, scale: 2
  end
end
