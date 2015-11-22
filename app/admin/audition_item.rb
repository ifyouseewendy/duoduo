ActiveAdmin.register AuditionItem do
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 6,
    if: -> {current_admin_user.finance_admin?}

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false

  index do
    selectable_column
    column :id
    column :auditable_type do |obj|
      obj.auditable.model_name.human
    end
    column :name do |obj|
      ref = obj.auditable
      name = ref.try(:name) || '#'
      link_to name, send("#{ref.class.name.underscore}_path", ref)
    end
    column :status do |obj|
      obj.status_i18n
    end
    column :created_at
    column :updated_at

    actions defaults: false
  end
end
