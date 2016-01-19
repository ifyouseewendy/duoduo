class AddCategoryAndStatusIndexToInvoiceSettings < ActiveRecord::Migration
  def change
    add_index :invoice_settings, [:category, :status]
  end
end
