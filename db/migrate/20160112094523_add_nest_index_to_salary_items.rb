class AddNestIndexToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :nest_index, :integer
    add_index :salary_items, :nest_index
  end
end
