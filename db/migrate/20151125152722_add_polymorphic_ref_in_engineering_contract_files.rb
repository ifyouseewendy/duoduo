class AddPolymorphicRefInEngineeringContractFiles < ActiveRecord::Migration
  def change
    change_table :engineering_contract_files do |t|
      t.belongs_to :engi_contract, polymorphic: true, index: { name: :idx_engi_contract_id_and_type }
    end
  end
end
