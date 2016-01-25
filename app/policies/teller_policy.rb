class TellerPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    raise Pundit::NotAuthorizedError, "locked" unless user.active?
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    return true if ActiveAdmin::Page === record
    scope.where(:id => record.id).exists?
  end

  def method_missing(method, *args, &block)
    user.super_admin? or user.teller?
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
