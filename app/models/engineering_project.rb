class EngineeringProject < ActiveRecord::Base
  belongs_to :engineering_customer
  belongs_to :engineering_corp
  has_and_belongs_to_many :engineering_staffs

  before_save :revise_fields

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_customer_id engineering_corp_id) if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end
  end

  def revise_fields
    self.project_range ||= -> {
      month = (project_end_date.to_date - project_start_date.to_date).to_i / 29
      "#{month} 月"
    }.call

    if (changed && [:project_amount, :admin_amount]).present?
      self.total_amount = project_amount + admin_amount
    end
  end

  def range
    [project_start_date, project_end_date]
  end

  def range_output
    "#{name}： #{project_start_date} - #{project_end_date}"
  end
end
