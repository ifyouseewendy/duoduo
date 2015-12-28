class AddSubCompanyReferencesToNormalCorporations < ActiveRecord::Migration
  def change
    add_reference :normal_corporations, :sub_company, index: true, foreign_key: true
  end
end
