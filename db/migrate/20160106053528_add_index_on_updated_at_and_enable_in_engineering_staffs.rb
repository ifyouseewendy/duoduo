class AddIndexOnUpdatedAtAndEnableInEngineeringStaffs < ActiveRecord::Migration
  def change
    add_index :engineering_staffs, [:updated_at, :enable]
  end
end
