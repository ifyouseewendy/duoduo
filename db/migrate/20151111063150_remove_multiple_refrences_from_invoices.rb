class RemoveMultipleRefrencesFromInvoices < ActiveRecord::Migration
  def change
    remove_reference :invoices, :salary_table, index: true, foreign_key: true
    remove_reference :invoices, :guard_salary_table, index: true, foreign_key: true
    remove_reference :invoices, :non_full_day_salary_table, index: true, foreign_key: true
  end
end
