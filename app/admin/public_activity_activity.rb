ActiveAdmin.register PublicActivity::Activity do
  index as: :block do |activity|
    render partial: 'public_activity_activities/display', locals: {activity: activity}
  end

end
