class AddEngineeringCorporationRefToEngineeringStaffs < ActiveRecord::Migration
  def change
    add_reference :engineering_staffs, :engineering_corporation, index: true, foreign_key: true
  end
end
