module ActAsSingleton
  extend ActiveSupport::Concern

  included do
    # private_class_method :new

    before_create :confirm_singularity

    private

      def confirm_singularity
        raise "#{self.class} is a Singleton class." if self.class.count > 0
      end
  end

  module ClassMethods

    def instance
      @_instance ||= (self.first || self.create)
    end
  end
end
