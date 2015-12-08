ActiveAdmin.register PublicActivity::Activity do
  menu \
    parent: I18n.t("activerecord.models.settings"),
    priority: 6

  config.batch_actions = false
  config.clear_action_items!

  index as: :block, download_links: false do |activity|
    render partial: 'public_activity_activities/display', locals: {activity: activity}
  end

  filter :owner_id, as: :select, collection: ->{ AdminUser.pluck(:name, :id) }
  filter :key_cont, as: :select, collection: [['创建', 'create'], ['更新', 'update'], ['删除', 'destroy']]
  filter :trackable_type
  filter :created_at
  # preserve_default_filters!
  # remove_filter :trackable_type
  # remove_filter :owner_type
  # remove_filter :key
  # remove_filter :parameters
  # remove_filter :updated_at
end
