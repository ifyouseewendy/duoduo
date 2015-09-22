class AddRefsToSalaryItems < ActiveRecord::Migration
  def change
    add_reference :salary_items, :salary_table, index: true, foreign_key: true
    add_reference :salary_items, :normal_staff, index: true, foreign_key: true
    add_reference :salary_items, :engineering_staff, index: true, foreign_key: true
  end
end
