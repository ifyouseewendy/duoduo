class AddSubCompanyReferencesToEngineeringProject < ActiveRecord::Migration
  def change
    add_reference :engineering_projects, :sub_company, index: true, foreign_key: true
  end
end
