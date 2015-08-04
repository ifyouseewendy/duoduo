ActiveAdmin.register Ticket do
  belongs_to :project

  permit_params :name
end
