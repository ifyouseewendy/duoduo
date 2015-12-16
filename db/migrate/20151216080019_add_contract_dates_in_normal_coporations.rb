class AddContractDatesInNormalCoporations < ActiveRecord::Migration
  def change
    add_column :normal_corporations, :contract_start_date, :date
    add_column :normal_corporations, :contract_end_date, :date
  end
end
