class AddRefundBankAndRefundAccountToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :refund_bank, :text
    add_column :invoices, :refund_account, :text
  end
end
