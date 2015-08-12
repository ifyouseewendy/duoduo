class NormalCorporation < ActiveRecord::Base
  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
end
