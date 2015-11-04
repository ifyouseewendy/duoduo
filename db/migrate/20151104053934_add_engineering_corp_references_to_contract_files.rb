class AddEngineeringCorpReferencesToContractFiles < ActiveRecord::Migration
  def change
    add_reference :contract_files, :engineering_corp, index: true, foreign_key: true
  end
end
