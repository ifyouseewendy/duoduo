class AddNestIndexIndexInEngineeringProjects < ActiveRecord::Migration
  def change
    add_index :engineering_projects, :nest_index
  end
end
