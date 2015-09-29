class ChangeDecimalScaleInInsuranceFundRates < ActiveRecord::Migration
  def change
    change_column :insurance_fund_rates, :pension,      :decimal, precision: 8, scale: 4
    change_column :insurance_fund_rates, :unemployment, :decimal, precision: 8, scale: 4
    change_column :insurance_fund_rates, :medical,      :decimal, precision: 8, scale: 4
    change_column :insurance_fund_rates, :injury,       :decimal, precision: 8, scale: 4
    change_column :insurance_fund_rates, :birth,        :decimal, precision: 8, scale: 4
  end
end
