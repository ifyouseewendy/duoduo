class RenameFileFieldInBigContracts < ActiveRecord::Migration
  def change
    rename_column :big_contracts, :file, :contract
  end
end
