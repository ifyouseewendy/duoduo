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
end
