ActiveAdmin.register Milestone do
  belongs_to :project

  permit_params :name
end
