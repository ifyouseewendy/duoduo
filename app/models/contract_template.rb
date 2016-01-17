class ContractTemplate < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.contract_identifier].compact.join(' - ') },
    }

  mount_uploader :contract, ContractTemplateUploader
end
