class AddOtherAmountToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :other_amount, :decimal, precision: 12, scale: 2
    add_index :salary_items, :other_amount
  end
end
