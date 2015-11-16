class CreateJoinTableEngineeringCustomerAndSubCompany < ActiveRecord::Migration
  def change
    create_join_table :engineering_customers, :sub_companies, id: false do |t|
      t.integer :engineering_customer_id, null: false
      t.integer :sub_company_id, null: false
      t.index [:engineering_customer_id, :sub_company_id], name: "idx_engineering_customer_and_sub_company"
      t.index [:sub_company_id, :engineering_customer_id], name: "idx_sub_company_and_engineering_customer"
    end
  end
end
