class EngineeringCorporation < ActiveRecord::Base
  has_and_belongs_to_many :sub_companies
  has_many :contract_files, through: :sub_companies
  has_many :engineering_staffs
  has_many :salary_tables

  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      # Bad implementations to keep headers in order
      # Use `column_names - %w(id created_at updated_at)` before, but when migrating a new field can't change its place.
      names = \
        [
          :id,
          :main_index,
          :nest_index,
          :name,
          :start_date,
          :project_date,
          :project_name,
          :project_amount,
          :admin_amount,
          :total_amount,
          :income_date,
          :income_amount,
          :outcome_date,
          :outcome_referee,
          :outcome_amount,
          :proof,
          :actual_project_amount,
          :actual_admin_amount,
          :already_get_contract,
          :already_sign_dispatch,
          :remark,
          :created_at,
          :updated_at
        ]

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end
  end

  def sub_company_names
    sub_companies.map(&:name)
  end
end
