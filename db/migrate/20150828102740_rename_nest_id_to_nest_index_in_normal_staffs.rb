class RenameNestIdToNestIndexInNormalStaffs < ActiveRecord::Migration
  def change
    rename_column :normal_staffs, :nest_id, :nest_index
  end
end
