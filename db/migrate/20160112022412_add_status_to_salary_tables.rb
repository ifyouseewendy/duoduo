class AddStatusToSalaryTables < ActiveRecord::Migration
  def change
    add_column :salary_tables, :status, :integer
    add_index :salary_tables, :status
  end
end
