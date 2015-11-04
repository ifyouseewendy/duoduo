ActiveAdmin.register EngineeringCustomer do
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 1

  index do
    selectable_column

    column :id
    column :name
    column :engineering_projects, sortable: :id do |obj|
      link_to "项目列表", engineering_customer_engineering_projects_path(obj)
    end
    column :engineering_projects, sortable: :id do |obj|
      link_to "员工列表", engineering_customer_engineering_staffs_path(obj)
    end
    (EngineeringCustomer.ordered_columns - [:id, :name]).each do |field|
      column field
    end
  end

  preserve_default_filters!
  remove_filter :engineering_projects
  remove_filter :engineering_staffs

end
