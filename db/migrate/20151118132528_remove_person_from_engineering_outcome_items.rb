class RemovePersonFromEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    remove_column :engineering_outcome_items, :person
  end
end
