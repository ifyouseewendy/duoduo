class AddStatusFieldToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :status, :integer, default: 0
  end
end
