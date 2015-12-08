ActiveAdmin.register PublicActivity::Activity do
  menu \
    parent: I18n.t("activerecord.models.settings"),
    priority: 6

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false

  index as: :block, download_links: false do |activity|
    render partial: 'public_activity_activities/display', locals: {activity: activity}
  end

end
