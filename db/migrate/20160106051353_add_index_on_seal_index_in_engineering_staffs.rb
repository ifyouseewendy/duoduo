class AddIndexOnSealIndexInEngineeringStaffs < ActiveRecord::Migration
  def change
    add_index :engineering_staffs, :seal_index
  end
end
