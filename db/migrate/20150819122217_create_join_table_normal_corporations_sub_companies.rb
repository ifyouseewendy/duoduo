class CreateJoinTableNormalCorporationsSubCompanies < ActiveRecord::Migration
  def change
    create_join_table :normal_corporations, :sub_companies, id: false do |t|
      t.integer :normal_corporation_id, null: false
      t.integer :sub_company_id, null: false
      t.index [:normal_corporation_id, :sub_company_id], name: "idx_on_normal_corporation_id_and_sub_company_id"
      t.index [:sub_company_id, :normal_corporation_id], name: "idx_sub_company_id_and_normal_corporation_id"
    end
  end
end
