class DropEngineeringCorporations < ActiveRecord::Migration
  def change
    drop_table :engineering_corporations
  end
end
