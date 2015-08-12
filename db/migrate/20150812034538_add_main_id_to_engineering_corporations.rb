class AddMainIdToEngineeringCorporations < ActiveRecord::Migration
  def change
    add_column :engineering_corporations, :main_id, :integer
  end
end
