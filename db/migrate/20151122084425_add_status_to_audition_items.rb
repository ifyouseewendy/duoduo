class AddStatusToAuditionItems < ActiveRecord::Migration
  def change
    add_column :audition_items, :status, :integer, default: 0
  end
end
