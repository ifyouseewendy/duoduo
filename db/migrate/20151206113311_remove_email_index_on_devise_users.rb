class RemoveEmailIndexOnDeviseUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP INDEX index_admin_users_on_email
    SQL
  end
end
