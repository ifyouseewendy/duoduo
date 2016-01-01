class RemoveJoinTableEngineeringCustomersSubCompany < ActiveRecord::Migration
  def change
    drop_join_table :engineering_customers, :sub_companies
  end
end
