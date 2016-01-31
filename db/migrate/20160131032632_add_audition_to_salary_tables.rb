class AddAuditionToSalaryTables < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    add_column :salary_tables, :audition, :hstore, default: {}
  end
end
