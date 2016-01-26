class AddLockedToEngineeringProjects < ActiveRecord::Migration
  def change
    add_column :engineering_projects, :locked, :boolean, default: false
    add_index :engineering_projects, :locked
  end
end
