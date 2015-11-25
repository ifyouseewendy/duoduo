class AddEngiContractTemplateToSubCompanies < ActiveRecord::Migration
  def change
    add_column :sub_companies, :engi_contract_template, :text
  end
end
