class EngineeringNormalSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringNormalSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy

  def create_salary_item(salary:, name:, identity_card: nil)
    # staff = find_staff(salary_table: salary_table, name: name, identity_card: identity_card)
    # raise "员工已录入工资条，姓名：#{staff.name}。为避免重复录入，请直接修改现有条目" if salary_table.salary_items.where(normal_staff_id: staff.id).count > 0
    self.engineering_project.engineering_staffs.each do |staff|
      item = salary_items.new(
        engineering_staff: staff,
        salary_deserve: 10000,
        social_insurance: 100,
        medical_insurance: 100,
        total_insurance: 200,
        salary_in_fact: 9800,
        remark: '备注'
      )
      # item.auto_revise!
      item.save!
    end
  end
end
