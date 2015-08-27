class AddContractsToNormalCorporations < ActiveRecord::Migration
  def change
    add_column :normal_corporations, :contracts, :text, array: true, default: []
  end
end
