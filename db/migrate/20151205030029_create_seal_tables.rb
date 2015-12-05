class CreateSealTables < ActiveRecord::Migration
  def change
    create_table :seal_tables do |t|
      t.text :name
      t.text :remark

      t.timestamps null: false
    end
  end
end
