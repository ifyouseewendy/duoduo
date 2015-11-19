class RemoveAlreadyGetContractFromEngineeringProjects < ActiveRecord::Migration
  def change
    remove_column :engineering_projects, :already_get_contract
  end
end
