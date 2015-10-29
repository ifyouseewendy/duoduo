class RemoveEngineeringCorporationReferenceFromEngineeringStaff < ActiveRecord::Migration
  def change
    remove_reference :engineering_staffs, :engineering_corporation, index: true, foreign_key: true
  end
end
