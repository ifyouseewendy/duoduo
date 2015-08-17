class EngineeringCorporation < ActiveRecord::Base
  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  def self.csv_headers(all: false)
    # Bad implementations to keep headers in order
    # Use `column_names - %w(id created_at updated_at)` before, but when migrating a new field can't change its place.
    headers = \
      [
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
        :jiyi_company_name
      ]
    return headers unless all

    [:id] + headers + [:created_at, :updated_at]
  end
end
