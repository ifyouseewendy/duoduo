class Project < ActiveRecord::Base
  has_many :tickets
  has_many :milestones

  validates_uniqueness_of :name
end
