class AddIndexOnStatusInEngineeringProjects < ActiveRecord::Migration
  def change
    add_index :engineering_projects, :status
  end
end
