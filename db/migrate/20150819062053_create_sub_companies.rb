class CreateSubCompanies < ActiveRecord::Migration
  def change
    create_table :sub_companies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
