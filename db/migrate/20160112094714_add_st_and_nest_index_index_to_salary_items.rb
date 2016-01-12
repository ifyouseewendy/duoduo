class AddStAndNestIndexIndexToSalaryItems < ActiveRecord::Migration
  def change
    add_index :salary_items, [:salary_table_id, :nest_index]
  end
end
