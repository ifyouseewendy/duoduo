class CreateEngineeringProjects < ActiveRecord::Migration
  def change
    create_table :engineering_projects do |t|
      t.text :name
      t.date :start_date
      t.date :project_start_date
      t.date :project_end_date
      t.text :project_range
      t.decimal :project_amount, precision: 8, scale: 2
      t.decimal :admin_amount, precision: 8, scale: 2
      t.decimal :total_amount, precision: 8, scale: 2
      t.date :income_date
      t.decimal :income_amount, precision: 8, scale: 2
      t.date :outcome_date
      t.text :outcome_referee
      t.decimal :outcome_amount, precision: 8, scale: 2
      t.text :proof
      t.boolean :already_get_contract
      t.boolean :already_sign_dispatch
      t.text :remark

      t.timestamps null: false
    end
  end
end
