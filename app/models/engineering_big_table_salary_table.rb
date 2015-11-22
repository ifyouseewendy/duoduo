class EngineeringBigTableSalaryTable < EngineeringSalaryTable
  has_many :salary_items, \
    class_name: EngineeringBigTableSalaryItem,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_table,
    dependent: :destroy

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

  def update_reference_url(url)
    uri = URI(url)
    url = [uri.path, uri.query].join('?')

    self.reference ||= EngineeringBigTableSalaryTableReference.new(engineering_salary_table: self)
    self.reference.url = url
    self.reference.save!
  end

  def url
    reference.try(:url)
  end
end
