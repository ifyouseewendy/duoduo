class RemoveEngineeringCorporationRefFromSalaryTables < ActiveRecord::Migration
  def change
    remove_reference :salary_tables, :engineering_corporation, index: true, foreign_key: true
  end
end
