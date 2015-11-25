class EngineeringContractFile < ActiveRecord::Base
  belongs_to :engineering_project

  mount_uploader :contract, ContractUploader

  enum role: [:normal, :proxy, :template]

  default_scope { order(created_at: :asc) }

  class << self
    def policy_class
      EngineeringPolicy
    end
  end
end
