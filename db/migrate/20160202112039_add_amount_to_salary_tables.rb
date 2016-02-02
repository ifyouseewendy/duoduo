class AddAmountToSalaryTables < ActiveRecord::Migration
  def change
    add_column :salary_tables, :amount, :decimal, precision: 8, scale: 2
    add_index :salary_tables, :amount

    SalaryTable.all.each do |st|
      st.amount = st.salary_items.pluck(:total_sum_with_admin_amount).map(&:to_f).sum.round(2)
      st.save
    end
  end
end
