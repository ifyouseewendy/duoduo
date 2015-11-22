class EngineeringBigTableSalaryTableReference < ActiveRecord::Base
  belongs_to :engineering_salary_table

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

end
