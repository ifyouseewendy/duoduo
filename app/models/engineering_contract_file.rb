class EngineeringContractFile < ActiveRecord::Base
  belongs_to :engineering_project

  mount_uploader :contract, ContractUploader

  enum role: [:normal, :proxy, :template]
end
