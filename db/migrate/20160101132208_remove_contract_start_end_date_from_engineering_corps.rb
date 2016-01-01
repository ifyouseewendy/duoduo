class RemoveContractStartEndDateFromEngineeringCorps < ActiveRecord::Migration
  def change
    remove_column :engineering_corps, :contract_start_date, :string
    remove_column :engineering_corps, :contract_end_date, :string
    remove_column :engineering_corps, :outcome_bank, :string
  end
end
