class EngineeringOutcomeItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human].compact.join(' - ') },
    }

  belongs_to :project, class: EngineeringProject, foreign_key: :engineering_project_id

  has_many :contract_files, class: EngineeringContractFile, dependent: :destroy, as: :engi_contract

  validates_presence_of :persons
  validate :validate_amount
  validate :validate_count

  default_scope { order('created_at DESC') }

  after_save :revise_fields

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

  def revise_fields
    if (changed & ['amount']).present?
      project.validate_outcome_amount
    end
  end

  def validate_amount
    sum = each_amount.map(&:to_f).sum.round(2)
    if sum != 0 && sum != amount
      errors.add(:each_amount, "回款金额（每人）之和不等于总回款金额")
    end
  end

  def validate_count
    fields = changed & ['each_amount', 'bank', 'account', 'address']

    if fields.present?
      fields.each do |field|
        errors.add(field, "#{self.class.human_attribute_name(field)}个数与回款人数不等")
      end
    end
  end
end
