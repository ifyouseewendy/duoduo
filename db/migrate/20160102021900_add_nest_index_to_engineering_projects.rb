class AddNestIndexToEngineeringProjects < ActiveRecord::Migration
  def change
    add_column :engineering_projects, :nest_index, :integer
  end
end
