class Project < ActiveRecord::Base
  has_many :tickets
  has_many :milestones

  validates_uniqueness_of :name

  def self.csv_headers
    (column_names - %w(id created_at updated_at) ).map(&:to_sym)
  end
end
