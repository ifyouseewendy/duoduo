class InsuranceFundRate < ActiveRecord::Base
  include ActAsSingleton

  # The model contains only 2 records, maybe called Doubleton
  def confirm_singularity
    raise "#{self.class} is a Singleton class." if self.class.count > 1
  end

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    # Create by seed, and id is solid
    def personal
      find(1)
    end

    def company
      find(2)
    end
  end
end
