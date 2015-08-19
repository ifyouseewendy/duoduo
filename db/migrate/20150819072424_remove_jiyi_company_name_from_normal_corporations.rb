class RemoveJiyiCompanyNameFromNormalCorporations < ActiveRecord::Migration
  def change
    remove_column :normal_corporations, :jiyi_company_name, :string
  end
end
