class RemoveNestIndexFromEngineeringStaff < ActiveRecord::Migration
  def change
    remove_column :engineering_staffs, :nest_index
  end
end
