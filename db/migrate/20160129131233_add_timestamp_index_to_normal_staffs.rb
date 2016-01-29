class AddTimestampIndexToNormalStaffs < ActiveRecord::Migration
  def change
    add_index :normal_staffs, :created_at
    add_index :normal_staffs, :updated_at
    add_index :normal_staffs, [:created_at, :in_contract]
    add_index :normal_staffs, [:updated_at, :in_contract]
  end
end
