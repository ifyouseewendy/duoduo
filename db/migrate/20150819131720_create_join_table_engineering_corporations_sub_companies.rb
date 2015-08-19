class CreateJoinTableEngineeringCorporationsSubCompanies < ActiveRecord::Migration
  def change
    create_join_table :engineering_corporations, :sub_companies, id: false do |t|
      t.integer :engineering_corporation_id, null: false
      t.integer :sub_company_id, null: false
      t.index [:engineering_corporation_id, :sub_company_id], name: "idx_on_engineering_corporation_id_and_sub_company_id"
      t.index [:sub_company_id, :engineering_corporation_id], name: "idx_sub_company_id_and_engineering_corporation_id"
    end
  end
end
