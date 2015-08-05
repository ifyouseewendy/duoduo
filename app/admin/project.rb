ActiveAdmin.register Project do
  sidebar "Project Details", only: [:show, :edit] do
    ul do
      li link_to "Tickets",    admin_project_tickets_path(project)
      li link_to "Milestones", admin_project_milestones_path(project)
    end
  end

  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column :description
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
end
