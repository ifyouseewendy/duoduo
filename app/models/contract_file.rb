class ContractFile < ActiveRecord::Base
  belongs_to :busi_contract, polymorphic: true

  mount_uploader :contract, ContractUploader

  validates_presence_of :contract
end
