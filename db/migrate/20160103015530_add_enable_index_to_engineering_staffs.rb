class AddEnableIndexToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_index :engineering_staffs, :enable
  end
end
