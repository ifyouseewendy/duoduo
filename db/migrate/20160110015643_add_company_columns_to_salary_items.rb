class AddCompanyColumnsToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :other_company, :decimal, precision: 8, scale: 2
  end
end
