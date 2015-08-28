class ChangeColumnDefaultInNormalCorporations < ActiveRecord::Migration
  def change
    change_column_default :normal_corporations, :admin_charge_type, 0
  end
end
