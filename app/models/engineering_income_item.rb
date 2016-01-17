class EngineeringIncomeItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

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
