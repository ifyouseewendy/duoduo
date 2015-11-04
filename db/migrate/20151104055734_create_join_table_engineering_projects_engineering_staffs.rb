class CreateJoinTableEngineeringProjectsEngineeringStaffs < ActiveRecord::Migration
  def change
    create_join_table :engineering_projects, :engineering_staffs, id: false do |t|
      t.integer :engineering_project_id, null: false
      t.integer :engineering_staff_id, null: false
      t.index [:engineering_project_id, :engineering_staff_id], name: "idx_on_engineering_project_id_and_engineering_staff_id"
      t.index [:engineering_staff_id, :engineering_project_id], name: "idx_on_engineering_staff_id_and_engineering_project_id"
    end
  end
end
