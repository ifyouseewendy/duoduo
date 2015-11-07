class EngineeringSalaryTable < ActiveRecord::Base
  class << self
    def types
      %w(
        EngineeringNormalSalaryTable
        EngineeringNormalWithTaxSalaryTable
        EngineeringBigTableSalaryTable
        EngineeringDongFangSalaryTable
      )
    end
  end
end
