class AddFullNameToNormalCorporations < ActiveRecord::Migration
  def change
    add_column :normal_corporations, :full_name, :text
  end
end
