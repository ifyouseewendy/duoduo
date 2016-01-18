class CreateInvoiceSettings < ActiveRecord::Migration
  def change
    create_table :invoice_settings do |t|
      t.integer :category, index: true
      t.text :code, index: true
      t.text :start_encoding, index: true
      t.integer :available_count, index: true
      t.integer :status, index: true
      t.text :remark, index: true

      t.timestamps null: false
    end
  end
end
