class AddNameIndexInSealItems < ActiveRecord::Migration
  def change
    add_index :seal_items, :name
  end
end
