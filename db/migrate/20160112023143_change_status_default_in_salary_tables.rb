class ChangeStatusDefaultInSalaryTables < ActiveRecord::Migration
  def change
    change_column_default :salary_tables, :status, 0
  end
end
