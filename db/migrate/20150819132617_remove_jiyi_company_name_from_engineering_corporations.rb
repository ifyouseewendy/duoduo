class RemoveJiyiCompanyNameFromEngineeringCorporations < ActiveRecord::Migration
  def change
    remove_column :engineering_corporations, :jiyi_company_name, :string
  end
end
