class CreateAuditionItems < ActiveRecord::Migration
  def change
    create_table :audition_items do |t|
      t.integer :auditable_id
      t.text :auditable_type

      t.timestamps null: false
    end
  end
end
