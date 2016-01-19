class AddSubCompanyNameToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :sub_company_name, :text, index: true
  end
end
