class RemoveJoinTableNormalCorporationsSubCompanies < ActiveRecord::Migration
  def change
    drop_join_table :normal_corporations, :sub_companies
  end
end
