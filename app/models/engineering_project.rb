class EngineeringProject < ActiveRecord::Base
  belongs_to :engineering_customer
  belongs_to :engineering_corp
  has_and_belongs_to_many :engineering_staffs

  before_save :revise_fields

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
end