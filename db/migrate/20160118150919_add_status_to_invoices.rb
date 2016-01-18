class AddStatusToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :status, :integer, default: 0
  end
end
