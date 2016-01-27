class AddSubCompanyReferencesToInvoices < ActiveRecord::Migration
  def change
    remove_index :invoices, :sub_company_name
    remove_column :invoices, :sub_company_name
    add_reference :invoices, :sub_company, index: true, foreign_key: true
  end
end
