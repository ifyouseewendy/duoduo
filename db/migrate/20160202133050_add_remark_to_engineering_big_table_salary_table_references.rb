class AddRemarkToEngineeringBigTableSalaryTableReferences < ActiveRecord::Migration
  def change
    add_column :engineering_big_table_salary_table_references, :remark, :text
  end
end
