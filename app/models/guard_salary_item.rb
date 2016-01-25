class GuardSalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:staff_name)].compact.join(' - ') },
    }

  belongs_to :guard_salary_table
  belongs_to :normal_staff

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_staff_id guard_salary_table_id) if without_foreign_keys

      names
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)\
        - [:salary_deserve_total, :total_deduct, :salary_in_fact, :total, :balance]
      fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        %i(id staff_attribute staff_account staff_name) \
          + self.ordered_columns(without_base_keys: true, without_foreign_keys: true)
      end
    end
  end

  def salary_deserve_total
    [
      salary_deserve,
      festival,
      dress_return
    ].map(&:to_f).sum
  end

  def total_deduct
    [
      physical_exam_deduct,
      dress_deduct,
      work_exam_deduct,
      other_deduct
    ].map(&:to_f).sum
  end

  def salary_in_fact
    salary_deserve_total - total_deduct
  end

  def total
    '?'
  end

  def balance
    '?'
  end

  def staff_attribute
  end

  def staff_account
    normal_staff.account
  end

  def staff_name
    normal_staff.name rescue ''
  end

end
