ActiveAdmin.register Ticket do
  belongs_to :project, optional: true

  include ImportSupport

  permit_params :name
end
