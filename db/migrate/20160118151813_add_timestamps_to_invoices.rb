class AddTimestampsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :created_at, :datetime, index: true
    add_column :invoices, :updated_at, :datetime, index: true
  end
end
