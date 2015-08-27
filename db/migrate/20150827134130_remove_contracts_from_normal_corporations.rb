class RemoveContractsFromNormalCorporations < ActiveRecord::Migration
  def change
    remove_column :normal_corporations, :contracts, :text
  end
end
