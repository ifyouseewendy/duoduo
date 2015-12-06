class AddSubCompanyReferencesToContractTemplates < ActiveRecord::Migration
  def change
    add_reference :contract_templates, :sub_company, index: true, foreign_key: true
  end
end
