class AddLaiTableToSalaryTables < ActiveRecord::Migration
  def change
    add_column :salary_tables, :lai_table, :text
    add_column :salary_tables, :daka_table, :text
  end
end
