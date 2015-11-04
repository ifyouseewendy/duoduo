class RemoveColumnsInEngineeringStaffs < ActiveRecord::Migration
  def change
    remove_columns :engineering_staffs, :nest_index, :company_name
  end
end
