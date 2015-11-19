class AddStatusToEngineeringProjects < ActiveRecord::Migration
  def change
    add_column :engineering_projects, :status, :integer, default: 0
  end
end
