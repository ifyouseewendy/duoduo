ActiveAdmin.register EngineeringCustomer do
  include ImportSupport

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

    actions
  end

  preserve_default_filters!
  remove_filter :engineering_projects
  remove_filter :engineering_staffs

  permit_params *EngineeringCustomer.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :name, as: :string
      f.input :telephone, as: :string
      f.input :identity_card, as: :string
      f.input :bank_account, as: :string
      f.input :bank_name, as: :string
      f.input :bank_opening_place, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :engineering_projects do |obj|
        link_to "项目列表", engineering_customer_engineering_projects_path(obj)
      end
      row :engineering_projects do |obj|
        link_to "员工列表", engineering_customer_engineering_staffs_path(obj)
      end

      (EngineeringCustomer.ordered_columns(without_foreign_keys: true) - [:id, :name]).map(&:to_sym).map do |field|
        row field
      end
    end
  end
end
