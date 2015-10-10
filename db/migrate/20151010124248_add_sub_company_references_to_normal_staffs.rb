class AddSubCompanyReferencesToNormalStaffs < ActiveRecord::Migration
  def change
    add_reference :normal_staffs, :sub_company, index: true, foreign_key: true
  end
end
