class RenameColumnInEngineeringCorporations < ActiveRecord::Migration
  def change
    rename_column :engineering_corporations, :main_id, :main_index
    rename_column :engineering_corporations, :nest_id, :nest_index
  end
end
