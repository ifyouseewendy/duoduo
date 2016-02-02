class AddAmountToGuardSalaryTables < ActiveRecord::Migration
  def change
    add_column :guard_salary_tables, :amount, :decimal, precision: 12, scale: 2
    add_index :guard_salary_tables, :amount

    GuardSalaryTable.all.each do |st|
      st.amount = st.salary_items.pluck(:total_sum).map(&:to_f).sum.round(2)
      st.save
    end
  end
end
