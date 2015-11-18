class AddEngineeringProjectReferencesToEngineeringIncomeItem < ActiveRecord::Migration
  def change
    add_reference :engineering_income_items, :engineering_project, index: true, foreign_key: true
  end
end
