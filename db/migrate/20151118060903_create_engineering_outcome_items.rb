class CreateEngineeringOutcomeItems < ActiveRecord::Migration
  def change
    create_table :engineering_outcome_items do |t|
      t.datetime :date
      t.decimal :amount, precision: 8, scale: 2
      t.text :person
      t.text :remark

      t.timestamps null: false
    end
  end
end
