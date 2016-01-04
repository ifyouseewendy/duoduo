ActiveAdmin.register SealTable do
  menu false
  # menu \
  #   parent: I18n.t("activerecord.models.engineering_business"),
  #   priority: 7

  index download_links: false do
    selectable_column

    column :name
    column :seal_items do |obj|
      link_to '人员列表', seal_table_seal_items_path(obj)
    end
    column :remark
    column :updated_at
    column :created_at

    actions
  end

  preserve_default_filters!
  remove_filter :seal_items
  filter :seal_items_name, as: :string

  permit_params { resource_class.column_names }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end
end
