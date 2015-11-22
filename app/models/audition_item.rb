class AuditionItem < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true

  enum status: [:init, :apply_audit, :already_audit]
end
