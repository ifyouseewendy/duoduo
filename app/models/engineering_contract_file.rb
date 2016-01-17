class EngineeringContractFile < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :engi_contract, polymorphic: true

  mount_uploader :contract, ContractUploader

  enum role: [:normal, :proxy, :template]

  default_scope { order(created_at: :asc) }

  class << self
    def policy_class
      EngineeringPolicy
    end
  end
end
