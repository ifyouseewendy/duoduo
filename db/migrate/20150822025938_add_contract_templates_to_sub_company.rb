class AddContractTemplatesToSubCompany < ActiveRecord::Migration
  def change
    add_column :sub_companies, :contract_templates, :text, array: true, default: []
  end
end
