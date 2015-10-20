class AddNonFullDaySalaryTableReferencesToInvoices < ActiveRecord::Migration
  def change
    add_reference :invoices, :non_full_day_salary_table, index: true, foreign_key: true
  end
end
