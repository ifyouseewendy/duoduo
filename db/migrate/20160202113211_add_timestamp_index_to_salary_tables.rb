class AddTimestampIndexToSalaryTables < ActiveRecord::Migration
  def change
    add_index :salary_tables, :updated_at
    add_index :salary_tables, :created_at
  end
end
