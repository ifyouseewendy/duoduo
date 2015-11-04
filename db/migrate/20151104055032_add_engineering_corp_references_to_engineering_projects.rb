class AddEngineeringCorpReferencesToEngineeringProjects < ActiveRecord::Migration
  def change
    add_reference :engineering_projects, :engineering_corp, index: true, foreign_key: true
  end
end
