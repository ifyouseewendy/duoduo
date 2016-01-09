class ContractFile < ActiveRecord::Base
  belongs_to :busi_contract, polymorphic: true

  mount_uploader :contract, ContractUploader
end
