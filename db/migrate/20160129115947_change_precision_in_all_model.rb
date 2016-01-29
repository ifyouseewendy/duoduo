class ChangePrecisionInAllModel < ActiveRecord::Migration
  def columns_of(klass, type)
    klass.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
  end

  def change
    columns_of(EngineeringBigTableSalaryItem, :decimal).each do |column|
      change_column :engineering_big_table_salary_items, column, :decimal, precision: 12, scale: 2
    end

    change_column :engineering_company_medical_insurance_amounts, :amount, :decimal, precision: 12, scale: 2
    change_column :engineering_company_social_insurance_amounts, :amount, :decimal, precision: 12, scale: 2
    change_column :engineering_dong_fang_salary_items, :salary_deserve, :decimal, precision: 12, scale: 2

    columns_of(EngineeringNormalSalaryItem, :decimal).each do |column|
      change_column :engineering_normal_salary_items, column, :decimal, precision: 12, scale: 2
    end

    columns_of(EngineeringNormalWithTaxSalaryItem, :decimal).each do |column|
      change_column :engineering_normal_with_tax_salary_items, column, :decimal, precision: 12, scale: 2
    end

    columns_of(GuardSalaryItem, :decimal).each do |column|
      change_column :guard_salary_items, column, :decimal, precision: 12, scale: 2
    end

    change_column :individual_income_taxes, :rate, :decimal, precision: 12, scale: 2

    columns_of(InsuranceFundRate, :decimal).each do |column|
      change_column :insurance_fund_rates, column, :decimal, precision: 12, scale: 2
    end

    columns_of(LaborContract, :decimal).each do |column|
      change_column :labor_contracts, column, :decimal, precision: 12, scale: 2
    end

    columns_of(NonFullDaySalaryItem, :decimal).each do |column|
      change_column :non_full_day_salary_items, column, :decimal, precision: 12, scale: 2
    end

    change_column :normal_corporations, :admin_charge_amount, :decimal, precision: 12, scale: 2

    columns_of(SalaryItem, :decimal).each do |column|
      change_column :salary_items, column, :decimal, precision: 12, scale: 2
    end
  end
end
