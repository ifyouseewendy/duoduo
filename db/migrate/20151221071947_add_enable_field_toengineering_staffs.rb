class AddEnableFieldToengineeringStaffs < ActiveRecord::Migration
  def change
    add_column :engineering_staffs, :enable, :boolean, default: true
  end
end
