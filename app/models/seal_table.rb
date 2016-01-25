class SealTable < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  has_many :seal_items, dependent: :destroy

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

  def latest_item_index
    index = seal_items.order(nest_index: :desc).first.try(:nest_index) || 0
    index + 1
  end
end
