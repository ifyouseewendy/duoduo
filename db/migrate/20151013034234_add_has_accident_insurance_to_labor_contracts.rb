class AddHasAccidentInsuranceToLaborContracts < ActiveRecord::Migration
  def change
    add_column :labor_contracts, :has_accident_insurance, :boolean
  end
end
