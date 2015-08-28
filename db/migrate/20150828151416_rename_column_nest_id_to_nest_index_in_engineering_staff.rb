class RenameColumnNestIdToNestIndexInEngineeringStaff < ActiveRecord::Migration
  def change
    rename_column :engineering_staffs, :nest_id, :nest_index
  end
end
