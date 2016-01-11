class AddInContractInNormalStaffs < ActiveRecord::Migration
  def change
    add_column :normal_staffs, :in_contract, :boolean, default: false, index: true
  end
end
