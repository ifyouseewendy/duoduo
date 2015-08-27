class NormalCorporation < ActiveRecord::Base
  has_and_belongs_to_many :sub_companies
  has_many :contract_files, through: :sub_companies

  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  def self.ordered_columns(without_base_keys: false, without_foreign_keys: false)
    names = column_names.map(&:to_sym)

    names -= %i(id created_at updated_at) if without_base_keys
    names -= %i(contracts) if without_foreign_keys

    names
  end

  def sub_company_names
    sub_companies.map(&:name)
  end
end
