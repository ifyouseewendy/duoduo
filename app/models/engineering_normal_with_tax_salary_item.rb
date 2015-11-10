class EngineeringNormalWithTaxSalaryItem < ActiveRecord::Base
  belongs_to :salary_table, \
    class_name: EngineeringNormalWithTaxSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items

  belongs_to :engineering_staff

  before_save :revise_fields

  class << self
    def create_by(table:, staff:, salary_deserve:)
      item = self.new(salary_table: table, engineering_staff: staff)

      item.salary_deserve     = salary_deserve
      item.social_insurance   = 407
      item.medical_insurance  = 249

      item.save!
    end
  end

  def revise_fields
    if (changed && [:salary_deserve, :social_insurance, :medical_insurance]).present?
      self.total_insurance  = self.social_insurance + self.medical_insurance
      self.total_amount     = self.salary_deserve + self.total_insurance
      self.tax              = IndividualIncomeTax.calculate(salary: self.total_amount)
      self.salary_in_fact   = self.total_amount - self.tax
    end
  end
end
