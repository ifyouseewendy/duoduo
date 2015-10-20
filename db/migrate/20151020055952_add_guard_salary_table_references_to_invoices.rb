class AddGuardSalaryTableReferencesToInvoices < ActiveRecord::Migration
  def change
    add_reference :invoices, :guard_salary_table, index: true, foreign_key: true
  end
end
