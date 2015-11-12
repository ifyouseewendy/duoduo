class CreateEngineeringContractFiles < ActiveRecord::Migration
  def change
    create_table :engineering_contract_files do |t|
      t.integer :role
      t.text :contract

      t.timestamps null: false
    end
  end
end
