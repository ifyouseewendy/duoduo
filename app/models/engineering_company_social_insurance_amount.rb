class EngineeringCompanySocialInsuranceAmount < ActiveRecord::Base
  class << self
    def policy_class
      EngineeringPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def current
      where(end_date: nil).last
    end

    def query_amount(date:)
      record = where("start_date <= ? AND end_date >= ?", date, date).first || current
      record.amount
    end
  end

end
