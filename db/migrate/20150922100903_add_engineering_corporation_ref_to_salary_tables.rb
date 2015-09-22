class AddEngineeringCorporationRefToSalaryTables < ActiveRecord::Migration
  def change
    add_reference :salary_tables, :engineering_corporation, index: true, foreign_key: true
  end
end
