class CreateEngineeringCorporations < ActiveRecord::Migration
  def change
    create_table :engineering_corporations do |t|
      t.integer   :nest_id
      t.text      :name,                   index: true
      t.date      :start_date,             index: true
      t.date      :project_date,           index: true
      t.text      :project_name,           index: true
      t.money     :project_amount,         index: true
      t.money     :admin_amount,           index: true
      t.money     :total_amount,           index: true
      t.date      :income_date,            index: true
      t.money     :income_amount,          index: true
      t.date      :outcome_date,           index: true
      t.text      :outcome_referee,        index: true
      t.money     :outcome_amount,         index: true
      t.text      :proof,                  index: true
      t.money     :actual_project_amount,  index: true
      t.money     :actual_admin_amount,    index: true
      t.boolean   :already_get_contract,   index: true
      t.boolean   :already_sign_dispatch,  index: true
      t.text      :remark
      t.text      :jiyi_company_name,      index: true

      t.timestamps null: false
    end
  end
end

