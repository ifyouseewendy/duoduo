class EngineeringDongFangSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringDongFangSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy
end
