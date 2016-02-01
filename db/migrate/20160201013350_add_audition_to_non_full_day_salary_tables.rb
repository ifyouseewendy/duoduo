class AddAuditionToNonFullDaySalaryTables < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    add_column :non_full_day_salary_tables, :audition, :hstore, default: {}
  end
end
