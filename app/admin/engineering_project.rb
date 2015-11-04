ActiveAdmin.register EngineeringProject do
  belongs_to :engineering_customer, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 2

  index do
    selectable_column

    column :id
    column :name
    column :engineering_customer, sortable: :id do |obj|
      link_to obj.engineering_customer.name, engineering_customer_path(obj.engineering_customer)
    end
    column :engineering_corp, sortable: :id do |obj|
      link_to obj.engineering_corp.name, engineering_corp_path(obj.engineering_corp)
    end
    (EngineeringProject.ordered_columns(without_foreign_keys: true) - [:id, :name]).each do |field|
      column field
    end
  end

  preserve_default_filters!
  remove_filter :engineering_staffs

end
