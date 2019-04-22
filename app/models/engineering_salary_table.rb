class EngineeringSalaryTable < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :project, \
    class: EngineeringProject,
    foreign_key: :engineering_project_id,
    required: true

  has_one :audition, as: :auditable, class_name: AuditionItem, dependent: :destroy

  has_many :references, class: EngineeringBigTableSalaryTableReference, dependent: :destroy
  accepts_nested_attributes_for :references, allow_destroy: true

  mount_uploader :attachment, Attachment

  validates_presence_of :start_date, :end_date

  class << self
    def policy_class
      EngineeringSalaryTablePolicy
    end

    def types
      [
        EngineeringNormalSalaryTable,
        EngineeringNormalWithTaxSalaryTable,
        EngineeringBigTableSalaryTable,
        EngineeringDongFangSalaryTable
      ]
    end

    def new_record_types
      [
        EngineeringNormalSalaryTable,
        EngineeringNormalWithTaxSalaryTable,
        EngineeringBigTableSalaryTable,
      ]
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_project_id) if without_foreign_keys

      names
    end

    def sum_fields
      [:amount]
    end

    def batch_fields
      [
        :remark
      ]
    end

    def batch_form_fields
      fields = batch_fields
      hash = {
      }
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

  end

  def audition_status
    audition.nil? ? nil : audition.status_i18n
  end

  def range
    [start_date, end_date]
  end

  def month_display
    start_date.strftime('%Y.%m')
  end

  def month_display_zh
    year = start_date.year
    range = [start_date.strftime("%m.%d"), end_date.strftime("%m.%d")].join("-")

    "#{year}年(#{range})日"
  end
end
