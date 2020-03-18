class AddIdNumbersToEngineeringOutcomeItem < ActiveRecord::Migration
  def change
    add_column :engineering_outcome_items, :id_numbers, :text, array: true, default: []
  end
end
