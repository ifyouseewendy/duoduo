class EngineeringCustomer < ActiveRecord::Base
  has_many :engineering_projects, dependent: :destroy
end
