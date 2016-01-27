class AddSubCompanyReferencesToInvoiceSettings < ActiveRecord::Migration
  def change
    add_reference :invoice_settings, :sub_company, index: true, foreign_key: true
  end
end
