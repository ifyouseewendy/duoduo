class AddSortOrderIndexIntoEngineeringProject < ActiveRecord::Migration
  def change
    add_index :engineering_projects, \
      [:engineering_customer_id, :nest_index], \
      order: {engineering_customer_id: :asc, nest_index: :asc},
      name: "idx_customer_and_nest_index_on_engi_project"
  end
end
