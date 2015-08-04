class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :name
      t.integer :project_id

      t.timestamps null: false
    end
  end
end
