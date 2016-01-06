class RemoveNationAndAddressInEngineeringStaffs < ActiveRecord::Migration
  def change
    remove_columns :engineering_staffs, :nation, :address
  end
end
