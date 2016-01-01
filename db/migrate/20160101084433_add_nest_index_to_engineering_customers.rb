class AddNestIndexToEngineeringCustomers < ActiveRecord::Migration
  def change
    add_column :engineering_customers, :nest_index, :integer, index: true
  end
end
