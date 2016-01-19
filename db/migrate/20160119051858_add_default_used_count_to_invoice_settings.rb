class AddDefaultUsedCountToInvoiceSettings < ActiveRecord::Migration
  def change
    change_column_default :invoice_settings, :used_count, 0
  end
end
