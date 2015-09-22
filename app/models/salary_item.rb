class SalaryItem < ActiveRecord::Base
  belongs_to :salary_table
  belongs_to :normal_staff
  belongs_to :engineering_staff

  def staff
    normal_staff or engineering_staff
  end
end
