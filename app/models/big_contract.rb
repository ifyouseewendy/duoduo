class BigContract < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :sub_company
  belongs_to :corporation, class: EngineeringCorp, foreign_key: :engineering_corp_id

  mount_uploader :contract, BigContractUploader

  scope :enable, ->{ where(enable: true) }

  def activate!
    self.update_attribute(:enable, true)
  end

  def deactivate!
    self.update_attribute(:enable, false)
  end

  def to_s
    [sub_company.name, corporation.name, start_date, end_date].join('-')
  end
end
