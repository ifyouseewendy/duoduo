class AddFieldsIntoEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    add_column :engineering_outcome_items, :bank, :text, array: true, default: []
    add_column :engineering_outcome_items, :address, :text, array: true, default: []
  end
end
