class ChangeColumnDateInEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    change_column :engineering_outcome_items, :date, :date
  end
end
