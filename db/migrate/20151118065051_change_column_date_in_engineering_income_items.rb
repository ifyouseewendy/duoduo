class ChangeColumnDateInEngineeringIncomeItems < ActiveRecord::Migration
  def change
    change_column :engineering_income_items, :date, :date
  end
end
