class AddStartDateToSalaryTables < ActiveRecord::Migration
  def change
    add_column :salary_tables, :start_date, :date
    add_index :salary_tables, :start_date
  end
end
