class ContractFile < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.contract_identifier].compact.join(' - ') },
    }

  belongs_to :busi_contract, polymorphic: true

  mount_uploader :contract, ContractUploader

  validates_presence_of :contract
end
