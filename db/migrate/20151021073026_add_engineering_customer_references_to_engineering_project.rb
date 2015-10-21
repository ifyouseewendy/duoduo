class AddEngineeringCustomerReferencesToEngineeringProject < ActiveRecord::Migration
  def change
    add_reference :engineering_projects, :engineering_customer, index: true, foreign_key: true
  end
end
