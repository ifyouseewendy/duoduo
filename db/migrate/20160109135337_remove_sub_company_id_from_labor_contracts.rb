class RemoveSubCompanyIdFromLaborContracts < ActiveRecord::Migration
  def change
    remove_index :labor_contracts, :sub_company_id
    remove_column :labor_contracts, :sub_company_id
  end
end
