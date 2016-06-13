class AddVisibleSubCompanyIdsToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :visible_sub_company_ids, :text, array: true, default: []
  end
end
