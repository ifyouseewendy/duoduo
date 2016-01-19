class AddCategoryAndCodeIndexToInvoiceSettings < ActiveRecord::Migration
  def change
    add_index :invoice_settings, [:category, :code]
  end
end
