class AddUpdatedAtIndexToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_index :engineering_staffs, :updated_at
  end
end
