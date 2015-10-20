class NonFullDaySalaryItem < ActiveRecord::Base
  belongs_to :salary_table
  belongs_to :normal_staff
end
