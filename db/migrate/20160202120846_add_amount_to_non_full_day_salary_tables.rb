class AddAmountToNonFullDaySalaryTables < ActiveRecord::Migration
  def change
    add_column :non_full_day_salary_tables, :amount, :decimal, precision: 12, scale: 2
    add_index :non_full_day_salary_tables, :amount

    NonFullDaySalaryTable.all.each do |st|
      st.amount = st.salary_items.pluck(:total_sum_with_admin_amount).map(&:to_f).sum.round(2)
      st.save
    end
  end
end
