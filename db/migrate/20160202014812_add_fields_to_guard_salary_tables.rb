class AddFieldsToGuardSalaryTables < ActiveRecord::Migration
  def change
    enable_extension 'hstore'

    add_column :guard_salary_tables, :lai_table, :text
    add_column :guard_salary_tables, :daka_table, :text
    add_column :guard_salary_tables, :status, :integer, default: 0
    add_column :guard_salary_tables, :audition, :hstore, default: {}
  end
end
