class RemoveEngiProjectRefInEngineeringContractFiles < ActiveRecord::Migration
  def change
    remove_reference :engineering_contract_files, :engineering_project, index: true
  end
end
