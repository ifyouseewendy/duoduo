class AddAccountToEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    add_column :engineering_outcome_items, :account, :text, array: true, default: []
  end
end
