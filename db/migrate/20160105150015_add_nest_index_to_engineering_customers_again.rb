class AddNestIndexToEngineeringCustomersAgain < ActiveRecord::Migration
  def change
    add_index :engineering_customers, :nest_index
  end
end
