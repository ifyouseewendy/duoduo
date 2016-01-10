class AddStatusInNormalCorporations < ActiveRecord::Migration
  def change
    add_column :normal_corporations, :status, :integer, index: true, default: 0
  end
end
