class RenameTableInvoice < ActiveRecord::Migration
  def change
    rename_table :invoices_tables, :invoices
  end
end
