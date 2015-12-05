ActiveAdmin.register SealItem do
  belongs_to :seal_table

  index download_links: false do
    selectable_column

    column :nest_index
    column :name
    column :remark
    column :updated_at
    column :created_at

    actions
  end

  preserve_default_filters!
  remove_filter :seal_table

  permit_params SealItem.column_names

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end
end
