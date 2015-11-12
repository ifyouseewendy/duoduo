class AddEngineeringProjectReferencesToEngineeringContractFiles < ActiveRecord::Migration
  def change
    add_reference :engineering_contract_files, :engineering_project, index: true, foreign_key: true
  end
end
