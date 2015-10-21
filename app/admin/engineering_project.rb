ActiveAdmin.register EngineeringProject do
  belongs_to :engineering_customer, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 1

end
