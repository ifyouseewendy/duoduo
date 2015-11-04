class EngineeringCorp < ActiveRecord::Base
  has_many :contract_files
  has_many :engineering_projects
end
