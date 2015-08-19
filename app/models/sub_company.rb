class SubCompany < ActiveRecord::Base
  has_and_belongs_to_many :normal_corporations
end
