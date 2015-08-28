class CreateEngineeringStaffs < ActiveRecord::Migration
  def change
    create_table :engineering_staffs do |t|
      t.integer :nest_id,       index: true
      t.text :name,             index: true
      t.text :company_name,     index: true
      t.text :identity_card,    index: true
      t.date :birth,            index: true
      t.integer :age,           index: true
      t.integer :gender,        index: true, default: 0
      t.text :nation,           index: true
      t.text :address,          index: true
      t.text :remark,           index: true

      t.timestamps null: false
    end
  end
end
