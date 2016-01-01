class BigContract < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :corporation, class: EngineeringCorp, foreign_key: :engineering_corp_id

  mount_uploader :contract, BigContractUploader

  scope :enable, ->{ where(enable: true) }
end
