class CreateIndividualIncomeTaxes < ActiveRecord::Migration
  def change
    create_table :individual_income_taxes do |t|
      t.integer :grade
      t.integer :tax_range_start
      t.integer :tax_range_end
      t.decimal :rate, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
