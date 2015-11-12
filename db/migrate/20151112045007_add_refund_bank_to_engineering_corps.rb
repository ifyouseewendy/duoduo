class AddRefundBankToEngineeringCorps < ActiveRecord::Migration
  def change
    add_column :engineering_corps, :outcome_bank, :text
  end
end
