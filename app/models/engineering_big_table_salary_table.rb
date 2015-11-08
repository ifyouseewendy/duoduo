class EngineeringBigTableSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringBigTableSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy
end
