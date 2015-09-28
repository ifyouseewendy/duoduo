class InsuranceFundRate < ActiveRecord::Base
  include ActAsSingleton

  # The model contains only 2 records, maybe called Dounbleton
  def confirm_singularity
    raise "#{self.class} is a Singleton class." if self.class.count > 1
  end
end
