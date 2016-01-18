class AddIndexOnTimestampsToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :created_at
    add_index :invoices, :updated_at
  end
end
