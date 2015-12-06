class CreateContractTemplates < ActiveRecord::Migration
  def change
    create_table :contract_templates do |t|
      t.text :contract

      t.timestamps null: false
    end
  end
end
