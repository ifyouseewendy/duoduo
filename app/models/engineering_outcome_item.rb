class EngineeringOutcomeItem < ActiveRecord::Base
  belongs_to :project, class: EngineeringProject, foreign_key: :engineering_project_id

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy, as: :engi_contract

  validates_presence_of :persons

  default_scope { order('created_at DESC') }

  class << self
    def policy_class
      EngineeringPolicy
    end
  end

  def add_contract_file(path:, role: :normal)
    self.contract_files.create!(
      contract: File.open(path),
      role: role
    )
  end

  def allocate(money: )
    count = persons.count

    fraction = money - money.floor
    avg = money.to_i / count
    mod = money.to_i % count

    res = [avg]*count
    res[0] += (mod + fraction).round(2)
    res
  end
end
