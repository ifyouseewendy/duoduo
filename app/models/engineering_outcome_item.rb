class EngineeringOutcomeItem < ActiveRecord::Base
  belongs_to :project, class: EngineeringProject, foreign_key: :engineering_project_id

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy, as: :engi_contract

  validates_presence_of :persons

  default_scope { order('created_at DESC') }

  class << self
    def policy_class
      EngineeringPolicy
    end
  end
end
