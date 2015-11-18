class AddPersonsToEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    add_column :engineering_outcome_items, :persons, :text, array: true, default: []
  end
end
