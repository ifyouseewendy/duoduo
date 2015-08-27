class AddContractToContractFiles < ActiveRecord::Migration
  def change
    add_column :contract_files, :contract, :text
  end
end
