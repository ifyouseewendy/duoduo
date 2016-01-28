class AddManagementToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :management, :text
    add_index :invoices, :management
  end
end
