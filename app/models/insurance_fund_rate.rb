class InsuranceFundRate < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  include ActAsSingleton

  # The model contains only 2 records, maybe called Doubleton
  def confirm_singularity
    raise "#{self.class} is a Singleton class." if self.class.count > 1
  end

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    # Create by seed, and id is solid
    def personal
      find_by_name('个人')
    end

    def company
      find_by_name('公司')
    end
  end
end
