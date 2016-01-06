class AddSealIndexInEngineeringStaffs < ActiveRecord::Migration
  def change
    add_column :engineering_staffs, :seal_index, :text
  end
end
