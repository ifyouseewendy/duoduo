class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :name
      t.integer :project_id

      t.timestamps null: false
    end
  end
end
