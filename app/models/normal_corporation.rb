class NormalCorporation < ActiveRecord::Base
  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  def self.ordered_columns
    (column_names - %w(id created_at updated_at) ).map(&:to_sym)
  end
end
