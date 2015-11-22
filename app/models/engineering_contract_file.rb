class EngineeringContractFile < ActiveRecord::Base
  belongs_to :engineering_project

  mount_uploader :contract, ContractUploader

  enum role: [:normal, :proxy, :template]

  class << self
    def policy_class
      EngineeringPolicy
    end
  end
end
