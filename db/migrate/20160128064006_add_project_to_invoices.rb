class AddProjectToInvoices < ActiveRecord::Migration
  def up
    add_reference :invoices, :project, polymorphic: true, index: true
  end

  def down
    remove_reference :invoices, :project, polymorphic: true, index: true
  end
end
