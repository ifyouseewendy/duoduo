class AddNormalCorporationRefToSalaryTables < ActiveRecord::Migration
  def change
    add_reference :salary_tables, :normal_corporation, index: true, foreign_key: true
  end
end
