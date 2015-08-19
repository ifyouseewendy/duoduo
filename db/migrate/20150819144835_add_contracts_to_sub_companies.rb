class AddContractsToSubCompanies < ActiveRecord::Migration
  def change
    add_column :sub_companies, :contracts, :text, array: true, default: []
  end
end
