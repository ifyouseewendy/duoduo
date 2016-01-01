class RemoveSubCompaniesReferencesFromEngineeringCorp < ActiveRecord::Migration
  def change
    remove_reference :engineering_corps, :sub_company, index: true, foreign_key: true
  end
end
