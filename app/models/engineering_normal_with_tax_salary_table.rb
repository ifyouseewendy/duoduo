class EngineeringNormalWithTaxSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringNormalWithTaxSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy
end
