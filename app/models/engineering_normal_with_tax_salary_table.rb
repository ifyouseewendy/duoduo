class EngineeringNormalWithTaxSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringNormalWithTaxSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy

  def validate_amount
    self.update_attribute(:amount, self.salary_items.map(&:total_amount).map(&:to_f).sum.round(2))
  end
end
