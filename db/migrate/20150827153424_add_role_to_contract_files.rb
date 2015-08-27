class AddRoleToContractFiles < ActiveRecord::Migration
  def change
    add_column :contract_files, :role, :integer, default: 0
  end
end
