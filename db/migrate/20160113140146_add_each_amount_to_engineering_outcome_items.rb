class AddEachAmountToEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    add_column :engineering_outcome_items, :each_amount, :text, array: true, default: []
  end
end
