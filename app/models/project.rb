class Project < ActiveRecord::Base
  has_many :tickets
  has_many :milestones
end
