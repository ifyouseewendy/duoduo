class EngineeringBigTableSalaryItem < ActiveRecord::Base
  belongs_to :salary_table, \
    class_name: EngineeringBigTableSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items

  belongs_to :staff, class: EngineeringStaff, foreign_key: :engineering_staff_id

  class << self
    def policy_class
      EngineeringSalaryItemPolicy
    end
  end

end
