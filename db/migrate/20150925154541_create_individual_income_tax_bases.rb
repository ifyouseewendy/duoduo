class CreateIndividualIncomeTaxBases < ActiveRecord::Migration
  def change
    create_table :individual_income_tax_bases do |t|
      t.integer :base

      t.timestamps null: false
    end
  end
end
