class AddNestIndexToLaborContracts < ActiveRecord::Migration
  def change
    add_column :labor_contracts, :nest_index, :integer
    add_index :labor_contracts, :nest_index
  end
end
