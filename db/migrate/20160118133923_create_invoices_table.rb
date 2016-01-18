class CreateInvoicesTable < ActiveRecord::Migration
  def change
    create_table :invoices_tables do |t|
      t.date :date, index: true
      t.text :code, index: true
      t.text :encoding, index: true
      t.integer :category, default: 0, index: true
      t.integer :scope, default: 0, index: true
      t.text :payer, index: true
      t.decimal :amount, precision: 8, scale: 2, index: true
      t.decimal :admin_amount, precision: 8, scale: 2, index: true
      t.decimal :total_amount, precision: 8, scale: 2, index: true
      t.text :contact, index: true
      t.date :income_date, index: true
      t.date :refund_date, index: true
      t.text :refund_person, index: true
      t.text :remark, index: true
    end
  end
end
