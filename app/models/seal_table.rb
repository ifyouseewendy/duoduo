class SealTable < ActiveRecord::Base
  has_many :seal_items, dependent: :destroy
end
