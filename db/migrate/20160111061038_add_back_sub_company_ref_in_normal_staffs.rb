class AddBackSubCompanyRefInNormalStaffs < ActiveRecord::Migration
  def change
    add_reference :normal_staffs, :sub_company, index: true
  end
end
