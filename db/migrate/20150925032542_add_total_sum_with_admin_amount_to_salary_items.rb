class AddTotalSumWithAdminAmountToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :total_sum_with_admin_amount, :decimal, precision: 8, scale: 2
  end
end
