ActiveAdmin.register ActiveAdmin::Comment, :as => "Comment" do
  permit_params *ActiveAdmin::Comment.column_names

  config.per_page = 30

  index do
    selectable_column

    column :id
    # column :namespace
    column :author, sortable: :author_id do |obj|
      obj.author.name
    end
    column :resource_type, sortable: :resource_type do |obj|
      obj.resource.class.model_name.human
    end
    column :resource, sortable: :resource_id do |obj|
      ref = obj.resource
      link_to ref.name, "/#{ref.class.to_s.underscore.pluralize}/#{obj.id}"
    end
    column :body
    column :created_at
    column :updated_at

    actions
  end

  preserve_default_filters!
  remove_filter :author_type
  remove_filter :namespace
end
