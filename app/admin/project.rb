ActiveAdmin.register Project do
  include ImportSupport

  # active_admin_import \
  #   validate: true,
  #   template: 'import' ,
  #   batch_transaction: true,
  #   template_object: ActiveAdminImport::Model.new(
  #     csv_options: {col_sep: ",", row_sep: nil, quote_char: nil},
  #     csv_headers: @resource.ordered_columns,
  #     force_encoding: :auto,
  #     allow_archive: false,
  # )

  menu false
  # menu \
  #   parent: "开发相关",
  #   priority: 2

  sidebar "Project Details", only: [:show, :edit] do
    ul do
      li link_to "Tickets",    project_tickets_path(project)
      li link_to "Milestones", project_milestones_path(project)
    end
  end

  permit_params :name

  index do
    selectable_column
    resource_class.ordered_columns.map{|field| column field}
    actions
  end

  index as: :grid do |project|
    div do
      h3 "#{project.name} - #{project.description}"
    end
  end

  index as: :block do |project|
    div for: project do
      resource_selection_cell project
      h2 auto_link project.name
      div simple_format project.description
    end
  end

  index as: :blog do |project|
    title :name
    body  :description
  end

  filter :name
  filter :description

  scope ->{ Date.today.strftime '%A' }, :all

  sidebar :help, priority: 20 do
    span "Need help? Email us at "
    link_to "help@example.com", "mailto:help@example.com"
  end

  collection_action :test_collection do
    render text: 'hello world'
  end

  collection_action :demo_collection do
    # Use authorized?(:demo, Project) to check status
    render text: 'hello world'
  end

  member_action :demo_member do
    # Use authorize!(:demo, Project) to raise ActiveAdmin::AccessDenied, and redirect to /admin
    render text: 'hello world'
  end

  # Batch Action
  batch_action :flag, confirm: "Are you sure??", form: {
    type: %w[Offensive Spam Other],
    reason: :text,
    notes:  :textarea,
    hide:   :checkbox,
    date:   :datepicker
  } do |ids|
    render text: "hello world"
  end

  # form do |f|
  #   inputs 'Details' do
  #     input :name
  #     input :created_at, label: "Publish Post At"
  #     li "Created at #{f.object.created_at}" unless f.object.new_record?
  #   end
  #   panel 'Markup' do
  #     "The following can be used in the content below..."
  #   end
  #   inputs 'Content', :description
  #   para "Press cancel to return to the list without saving."
  #   actions
  # end

  form do |f|
    tabs do
      tab 'Basic' do
        f.inputs 'Basic Details' do
          f.input :name
          f.input :created_at
        end
      end

      tab 'Advanced' do
        f.inputs 'Advanced Details' do
          f.input :description
        end
      end
    end
    f.actions
  end

  # show do
  #   h3 project.name
  #   div do
  #     simple_format project.description
  #   end
  # end

  show do
    tabs do
      tab "Tab 1" do
        panel "Project Details" do
          attributes_table_for project do
            row :name
            row 'Tags' do
              project.tickets.each do |ticket|
                a ticket.name, href: admin_project_path
                text_node "&nbsp".html_safe
              end
            end
          end
        end
      status_tag 'active', :ok, class: 'important', id: 'status_123', label: 'on'
      end
      tab "Tab 2" do
        attributes_table do
          row :name
          row :description
        end
        active_admin_comments
      end
    end
  end


  action_item :view, only: :show do
    link_to 'View on site', "http://baidu.com"
  end

  sidebar "Details", only: :show do
    attributes_table_for project do
      row :name
      row :description
    end
  end
end
