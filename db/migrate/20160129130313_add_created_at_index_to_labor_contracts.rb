class AddCreatedAtIndexToLaborContracts < ActiveRecord::Migration
  def change
    add_index :labor_contracts, :created_at
    add_index :labor_contracts, :updated_at
  end
end
