class EngineeringSalaryTable < ActiveRecord::Base
  belongs_to :engineering_project

  has_one :reference, class_name: EngineeringBigTableSalaryTableReference, dependent: :destroy

  has_one :audition, as: :auditable, class_name: AuditionItem, dependent: :destroy

  class << self
    def policy_class
      EngineeringPolicy
    end

    def types
      [
        EngineeringNormalSalaryTable,
        EngineeringNormalWithTaxSalaryTable,
        EngineeringBigTableSalaryTable,
        EngineeringDongFangSalaryTable
      ]
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_project_id) if without_foreign_keys

      names
    end

  end

  def audition_status
    audition.nil? ? nil : audition.status_i18n
  end
end
