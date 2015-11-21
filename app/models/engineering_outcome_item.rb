class EngineeringOutcomeItem < ActiveRecord::Base
  belongs_to :project, class: EngineeringProject, foreign_key: :engineering_project_id

  validates_presence_of :persons

  default_scope { order('created_at DESC') }
end
