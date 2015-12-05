class AddReferencesSealTableToSealItems < ActiveRecord::Migration
  def change
    add_reference :seal_items, :seal_table, index: true, foreign_key: true
  end
end
