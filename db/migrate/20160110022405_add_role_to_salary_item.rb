class AddRoleToSalaryItem < ActiveRecord::Migration
  def change
    add_column :salary_items, :role, :integer, default: 0
    add_index :salary_items, :role
  end
end
