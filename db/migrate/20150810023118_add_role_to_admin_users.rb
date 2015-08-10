class AddRoleToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :integer, default: 0
  end
end
