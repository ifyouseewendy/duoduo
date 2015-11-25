class EngineeringContractFile < ActiveRecord::Base
  belongs_to :engi_contract, polymorphic: true

  mount_uploader :contract, ContractUploader

  enum role: [:normal, :proxy, :template]

  default_scope { order(created_at: :asc) }

  class << self
    def policy_class
      EngineeringPolicy
    end
  end
end
