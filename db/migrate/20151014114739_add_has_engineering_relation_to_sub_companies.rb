class AddHasEngineeringRelationToSubCompanies < ActiveRecord::Migration
  def change
    add_column :sub_companies, :has_engineering_relation, :boolean
  end
end
