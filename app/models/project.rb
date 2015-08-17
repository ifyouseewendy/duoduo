class Project < ActiveRecord::Base
  has_many :tickets
  has_many :milestones

  validates_uniqueness_of :name

  def self.ordered_columns(all: false)
    return column_names.map(&:to_sym) if all
    (column_names - %w(id created_at updated_at) ).map(&:to_sym)
  end
end
