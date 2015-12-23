class AddAliasNameToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_column :engineering_staffs, :alias_name, :text
  end
end
