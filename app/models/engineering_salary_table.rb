class EngineeringSalaryTable < ActiveRecord::Base
  belongs_to :engineering_project

  class << self
    def types
      [
        EngineeringNormalSalaryTable,
        EngineeringNormalWithTaxSalaryTable,
        EngineeringBigTableSalaryTable,
        EngineeringDongFangSalaryTable
      ]
    end
  end
end
