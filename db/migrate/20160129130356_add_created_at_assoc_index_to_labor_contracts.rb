class AddCreatedAtAssocIndexToLaborContracts < ActiveRecord::Migration
  def change
    add_index :labor_contracts, [:created_at, :in_contract]
    add_index :labor_contracts, [:updated_at, :in_contract]
  end
end
