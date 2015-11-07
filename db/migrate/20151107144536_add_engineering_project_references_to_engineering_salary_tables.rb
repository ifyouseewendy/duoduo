class AddEngineeringProjectReferencesToEngineeringSalaryTables < ActiveRecord::Migration
  def change
    add_reference :engineering_salary_tables, :engineering_project, index: true, foreign_key: true
  end
end
