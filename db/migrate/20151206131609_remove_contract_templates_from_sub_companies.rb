class RemoveContractTemplatesFromSubCompanies < ActiveRecord::Migration
  def change
    remove_column :sub_companies, :contract_templates
  end
end
