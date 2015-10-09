class RenameInReleaseToInContractInNormalStaffs < ActiveRecord::Migration
  def change
    rename_column(:normal_staffs, :in_release, :in_contract)
  end
end
