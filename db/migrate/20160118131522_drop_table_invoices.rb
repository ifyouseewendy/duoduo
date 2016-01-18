class DropTableInvoices < ActiveRecord::Migration
  def change
    drop_table :invoices
  end
end
