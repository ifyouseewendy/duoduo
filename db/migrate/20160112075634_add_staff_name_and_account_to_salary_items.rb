class AddStaffNameAndAccountToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :staff_name, :text
    add_index :salary_items, :staff_name
    add_column :salary_items, :staff_account, :text
    add_index :salary_items, :staff_account
  end
end
