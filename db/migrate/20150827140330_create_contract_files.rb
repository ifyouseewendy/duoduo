class CreateContractFiles < ActiveRecord::Migration
  def change
    create_table :contract_files do |t|
      t.references :sub_company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
