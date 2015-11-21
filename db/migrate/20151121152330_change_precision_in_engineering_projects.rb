class ChangePrecisionInEngineeringProjects < ActiveRecord::Migration
  def fields
    %i(project_amount admin_amount total_amount income_amount outcome_amount)
  end

  def change
    fields.each do |field|
      change_column :engineering_projects, field, :decimal, precision: 12, scale: 2
    end
  end
end
