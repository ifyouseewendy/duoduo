class RemoveClolumnOutcomeBankFromEngineeringProjects < ActiveRecord::Migration
  def change
    remove_column :engineering_projects, :outcome_bank
  end
end
