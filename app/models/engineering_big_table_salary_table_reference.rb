class EngineeringBigTableSalaryTableReference < ActiveRecord::Base
  belongs_to :engineering_salary_table

  belongs_to :salary_table, class: EngineeringSalaryTable, foreign_key: :engineering_salary_table_id

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

end
