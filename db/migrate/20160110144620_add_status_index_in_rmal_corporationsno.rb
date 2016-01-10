class AddStatusIndexInRmalCorporationsno < ActiveRecord::Migration
  def change
    add_index :normal_corporations, :status
  end
end
