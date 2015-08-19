class NormalCorporation < ActiveRecord::Base
  has_and_belongs_to_many :sub_companies

  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  def self.ordered_columns(all: false)
    return column_names.map(&:to_sym) if all
    (column_names - %w(id created_at updated_at) ).map(&:to_sym)
  end

  def sub_company_name
    sub_company.name
  end
end
