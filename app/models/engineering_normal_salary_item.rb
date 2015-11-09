class EngineeringNormalSalaryItem < ActiveRecord::Base
  belongs_to :salary_table, \
    class_name: EngineeringNormalSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items

  belongs_to :engineering_staff

  class << self
    def create_by(table:, staff:, salary_in_fact:)
      item = self.new(salary_table: table, engineering_staff: staff)
      item.salary_in_fact =  salary_in_fact
      item.social_insurance = 407
      item.medical_insurance = 249
      item.total_insurance = 407 + 249
      item.salary_deserve = salary_in_fact - 407 - 249

      item.save!
    end
  end
end
