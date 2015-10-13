class AddNestIndexToNormalStaffs < ActiveRecord::Migration
  def change
    add_column :normal_staffs, :nest_index, :integer
  end
end
