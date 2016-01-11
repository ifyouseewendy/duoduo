class RemoveSubCompanyRefFromNormalStaffs < ActiveRecord::Migration
  def change
    remove_index :normal_staffs, :sub_company_id
    remove_column :normal_staffs, :sub_company_id
  end
end
