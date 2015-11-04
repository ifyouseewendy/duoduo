ActiveAdmin.register EngineeringCorp do

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 3

  preserve_default_filters!
  remove_filter :engineering_projects
  remove_filter :contract_files
end
