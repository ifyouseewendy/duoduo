class AddNormalCorporationRefToNormalStaffs < ActiveRecord::Migration
  def change
    add_reference :normal_staffs, :normal_corporation, index: true, foreign_key: true
  end
end
