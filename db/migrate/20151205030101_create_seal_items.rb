class CreateSealItems < ActiveRecord::Migration
  def change
    create_table :seal_items do |t|
      t.integer :nest_index
      t.text :name
      t.text :remark

      t.timestamps null: false
    end
  end
end
