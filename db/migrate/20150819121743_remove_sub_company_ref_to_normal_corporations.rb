class RemoveSubCompanyRefToNormalCorporations < ActiveRecord::Migration
  def change
    remove_reference :normal_corporations, :sub_company, index: true, foreign_key: true
  end
end
