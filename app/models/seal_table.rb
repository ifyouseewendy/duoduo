class SealTable < ActiveRecord::Base
  has_many :seal_items, dependent: :destroy

  def latest_item_index
    index = seal_items.order(nest_index: :desc).first.try(:nest_index) || 0
    index + 1
  end
end
