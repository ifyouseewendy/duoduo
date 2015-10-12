class Ticket < ActiveRecord::Base
  belongs_to :project

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(project_id) if without_foreign_keys

      names
    end
  end
end
