class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :salary_table, index: true, foreign_key: true
      t.date :release_date
      t.text :encoding
      t.text :payer
      t.text :project_name
      t.string :amount
      t.decimal :total_amount, precision: 8, scale: 2
      t.text :contact_person
      t.text :refund_person
      t.date :income_date
      t.date :refund_date

      t.timestamps null: false
    end
  end
end
