class AddEngineeringCustomerReferencesToEngineeringStaff < ActiveRecord::Migration
  def change
    add_reference :engineering_staffs, :engineering_customer, index: true, foreign_key: true
  end
end
