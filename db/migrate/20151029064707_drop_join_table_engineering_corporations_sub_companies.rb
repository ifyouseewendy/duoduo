class DropJoinTableEngineeringCorporationsSubCompanies < ActiveRecord::Migration
  def change
    drop_join_table :engineering_corporations, :sub_companies
  end
end
