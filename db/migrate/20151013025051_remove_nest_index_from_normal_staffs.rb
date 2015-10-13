class RemoveNestIndexFromNormalStaffs < ActiveRecord::Migration
  def change
    remove_column :normal_staffs, :nest_index
  end
end
