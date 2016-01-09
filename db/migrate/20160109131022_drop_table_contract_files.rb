class DropTableContractFiles < ActiveRecord::Migration
  def change
    drop_table :contract_files
  end
end
