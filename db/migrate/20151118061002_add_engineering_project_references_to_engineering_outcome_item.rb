class AddEngineeringProjectReferencesToEngineeringOutcomeItem < ActiveRecord::Migration
  def change
    add_reference :engineering_outcome_items, :engineering_project, index: true, foreign_key: true
  end
end
