class AddNestIndexToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_column :engineering_staffs, :nest_index, :integer
  end
end
