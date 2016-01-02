class BigContract < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :corporation, class: EngineeringCorp, foreign_key: :engineering_corp_id

  mount_uploader :contract, BigContractUploader

  scope :enable, ->{ where(enable: true) }

  def activate!
    corporation.big_contracts.enable.each{|bc| bc.update_attribute(:enable, false)}
    self.update_attribute(:enable, true)
  end
end
