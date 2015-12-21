class CreateJoinTableEngineeringCorpsSubCompanies < ActiveRecord::Migration
  def change
    create_join_table :engineering_corps, :sub_companies, id: false do |t|
      t.integer :engineering_corp_id, null: false
      t.integer :sub_company_id, null: false
      t.index [:engineering_corp_id, :sub_company_id], name: "idx_on_engineering_corp_id_and_sub_company_id"
      t.index [:sub_company_id, :engineering_corp_id], name: "idx_sub_company_id_and_engineering_corp_id"
    end
  end
end
