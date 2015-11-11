class AddInvoicableReferencesToInvoices < ActiveRecord::Migration
  def change
    add_reference :invoices, :invoicable, polymorphic: true, index: true
  end
end
