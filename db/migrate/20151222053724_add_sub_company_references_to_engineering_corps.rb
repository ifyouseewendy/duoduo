class AddSubCompanyReferencesToEngineeringCorps < ActiveRecord::Migration
  def change
    add_reference :engineering_corps, :sub_company, index: true, foreign_key: true
  end
end
