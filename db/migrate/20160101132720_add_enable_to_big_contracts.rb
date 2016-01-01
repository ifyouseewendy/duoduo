class AddEnableToBigContracts < ActiveRecord::Migration
  def change
    add_column :big_contracts, :enable, :boolean, default: false
  end
end
