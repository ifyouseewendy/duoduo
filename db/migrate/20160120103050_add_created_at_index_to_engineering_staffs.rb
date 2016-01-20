class AddCreatedAtIndexToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_index :engineering_staffs, :created_at
  end
end
