class NormalCorporation < ActiveRecord::Base
  has_and_belongs_to_many :sub_companies
  has_many :contract_files, through: :sub_companies
  has_many :normal_staffs

  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  enum admin_charge_type: [:by_rate, :by_count]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def admin_charge_types_option
      admin_charge_types.keys.map.with_index{|k,i| [I18n.t("activerecord.attributes.normal_corporation.admin_charge_types.#{k}"), i]}
    end
  end

  def sub_company_names
    sub_companies.map(&:name)
  end
end
