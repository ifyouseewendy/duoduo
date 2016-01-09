ActiveAdmin.register Ticket do
  belongs_to :project, optional: true

  menu false
  # menu \
  #   parent: "开发相关",
  #   priority: 3

  include ImportSupport

  permit_params :name
end
