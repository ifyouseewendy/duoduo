class AddRefundBankToEngineeringProjects < ActiveRecord::Migration
  def change
    add_column :engineering_projects, :outcome_bank, :text
  end
end
