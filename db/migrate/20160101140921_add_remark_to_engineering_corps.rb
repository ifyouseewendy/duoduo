class AddRemarkToEngineeringCorps < ActiveRecord::Migration
  def change
    add_column :engineering_corps, :remark, :text
  end
end
