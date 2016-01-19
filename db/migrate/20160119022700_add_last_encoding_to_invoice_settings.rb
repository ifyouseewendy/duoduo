class AddLastEncodingToInvoiceSettings < ActiveRecord::Migration
  def change
    add_column :invoice_settings, :last_encoding, :text
    add_index :invoice_settings, :last_encoding

    add_column :invoice_settings, :used_count, :integer
    add_index :invoice_settings, :used_count
  end
end
