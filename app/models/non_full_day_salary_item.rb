class NonFullDaySalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:staff_name)].compact.join(' - ') },
    }

  belongs_to :non_full_day_salary_table
  belongs_to :normal_staff

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_staff_id non_full_day_salary_table_id) if without_foreign_keys

      names
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)\
        - [:salary_in_fact, :total]
      fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        %i(id staff_category staff_account staff_name) \
          + self.ordered_columns(without_base_keys: true, without_foreign_keys: true)
      end
    end
  end

  def salary_deserve
    work_hour * work_wage rescue 0
  end

  def deduct
    [tax, other].map(&:to_f).sum
  end

  def salary_in_fact
    salary_deserve - deduct
  end

  def total
    '?'
  end

  def staff_category
    nil
  end

  def staff_account
    normal_staff.account
  end

  def staff_name
    normal_staff.name rescue ''
  end

end
