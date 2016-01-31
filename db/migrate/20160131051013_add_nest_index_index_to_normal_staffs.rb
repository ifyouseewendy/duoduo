class AddNestIndexIndexToNormalStaffs < ActiveRecord::Migration
  def change
    add_index :normal_staffs, :nest_index
  end
end
