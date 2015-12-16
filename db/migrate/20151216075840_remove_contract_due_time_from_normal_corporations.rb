class RemoveContractDueTimeFromNormalCorporations < ActiveRecord::Migration
  def change
    remove_column :normal_corporations, :contract_due_time
  end
end
