class EngineeringPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    raise Pundit::NotAuthorizedError, "locked" unless user.active?
    @user = user
    @record = record
  end

  def index?
    return false if user.business?

    true
  end

  def show?
    return false if user.business?

    return true if ActiveAdmin::Page === record
    scope.where(:id => record.id).exists?
  end

  def method_missing(method, *args, &block)
    user.super_admin? or user.finance?
  end

  def respond_to?(method, *)
    true
  end

  def scope
    Scope.new(user, record.class).resolve
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

  end
end
