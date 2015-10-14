class RemoveColumnsFromNormalCorporations < ActiveRecord::Migration
  def change
    remove_column :normal_corporations, :stuff_count, :string
    remove_column :normal_corporations, :insurance_count, :string
  end
end
