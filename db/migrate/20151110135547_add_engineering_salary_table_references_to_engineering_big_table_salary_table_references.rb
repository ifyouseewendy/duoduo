class AddEngineeringSalaryTableReferencesToEngineeringBigTableSalaryTableReferences < ActiveRecord::Migration
  def change
    add_reference\
      :engineering_big_table_salary_table_references,\
      :engineering_salary_table,\
      index: {name: 'idx_engineering_big_table_reference_of_salary_table'},
      foreign_key: true
  end
end
