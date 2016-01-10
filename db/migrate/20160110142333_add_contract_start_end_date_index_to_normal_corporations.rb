class AddContractStartEndDateIndexToNormalCorporations < ActiveRecord::Migration
  def change
    add_index :normal_corporations, :contract_start_date
    add_index :normal_corporations, :contract_end_date
  end
end
