class AddNonFullDaySalaryTableReferencesToNonFullDaySalaryItems < ActiveRecord::Migration
  def change
    add_reference :non_full_day_salary_items, :non_full_day_salary_table, index: true, foreign_key: true
  end
end
