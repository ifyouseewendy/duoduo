class EngineeringIncomeItem < ActiveRecord::Base
  belongs_to :project, class: EngineeringProject, foreign_key: :engineering_project_id

  validates_presence_of :date, :amount

  default_scope { order('created_at DESC') }

  after_save :revise_fields

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

  def revise_fields
    if (changed & ['amount']).present?
      project.validate_income_amount
    end
  end
end
