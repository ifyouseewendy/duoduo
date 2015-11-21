class ChangePrecisionInIncomeAndOutcomeItems < ActiveRecord::Migration
  def change
    change_column :engineering_income_items, :amount, :decimal, precision: 12, scale: 2
    change_column :engineering_outcome_items, :amount, :decimal, precision: 12, scale: 2
  end
end
