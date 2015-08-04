ActiveAdmin.register Project do
  sidebar "Project Details", only: [:show, :edit] do
    ul do
      li link_to "Tickets",    admin_project_tickets_path(project)
      li link_to "Milestones", admin_project_milestones_path(project)
    end
  end

  permit_params :name
end
