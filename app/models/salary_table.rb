class SalaryTable < ActiveRecord::Base
  belongs_to :normal_corporation
  belongs_to :engineering_corporation

  has_many :salary_items

  def corporation
    normal_corporation or engineering_corporation
  end
end
