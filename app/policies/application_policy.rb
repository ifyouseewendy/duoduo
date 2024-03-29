class ApplicationPolicy
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

  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    update?
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def destroy_all?
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

  def import?
    true
  end
end
