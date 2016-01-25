class ChangePrecisionInInvoices < ActiveRecord::Migration
  def change
    change_column :invoices, :amount, :decimal, precision: 12, scale: 2
    change_column :invoices, :admin_amount, :decimal, precision: 12, scale: 2
    change_column :invoices, :total_amount, :decimal, precision: 12, scale: 2
  end
end
