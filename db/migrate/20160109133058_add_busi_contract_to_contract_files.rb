class AddBusiContractToContractFiles < ActiveRecord::Migration
  def change
    change_table :contract_files do |t|
      t.belongs_to :busi_contract, polymorphic: true, index: { name: :idx_busi_contract_id_and_type }
    end
  end
end
