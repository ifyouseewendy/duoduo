class NonFullDaySalaryTable < ActiveRecord::Base
  belongs_to :normal_corporation
  has_many :non_full_day_salary_items, dependent: :destroy
end
