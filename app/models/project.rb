class Project < ActiveRecord::Base
  has_many :tickets
  has_many :milestones

  validates_uniqueness_of :name

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end
  end
end
