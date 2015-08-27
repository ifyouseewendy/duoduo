class RemoveContractsFromSubCompany < ActiveRecord::Migration
  def change
    remove_column :sub_companies, :contracts, :text
  end
end
