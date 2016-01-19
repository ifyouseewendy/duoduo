class AddIndexOnSubCompanyNameToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :sub_company_name
  end
end
