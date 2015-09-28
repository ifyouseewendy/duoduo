class CreateInsuranceFundRates < ActiveRecord::Migration
  def change
    create_table :insurance_fund_rates do |t|
      t.text    :name
      t.decimal :pension,              precision: 8, scale: 2
      t.decimal :unemployment,         precision: 8, scale: 2
      t.decimal :medical,              precision: 8, scale: 2
      t.decimal :injury,               precision: 8, scale: 2
      t.decimal :birth,                precision: 8, scale: 2
      t.decimal :house_accumulation,   precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
