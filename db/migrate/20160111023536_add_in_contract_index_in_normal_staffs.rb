class AddInContractIndexInNormalStaffs < ActiveRecord::Migration
  def change
    add_index :normal_staffs, :in_contract
    add_index :normal_staffs, [:in_service, :in_contract]
  end
end
