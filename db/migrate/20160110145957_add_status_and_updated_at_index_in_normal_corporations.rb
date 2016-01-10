class AddStatusAndUpdatedAtIndexInNormalCorporations < ActiveRecord::Migration
  def change
    add_index :normal_corporations, [:status, :updated_at]
  end
end
