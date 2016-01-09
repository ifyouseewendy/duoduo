class CreateTableContractFilesAgain < ActiveRecord::Migration
  def change
    create_table :contract_files do |t|
      t.text :contract

      t.timestamps null: false
    end
  end
end
