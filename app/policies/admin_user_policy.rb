class AdminUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def reset_password?
    user.admin?
  end

  def lock?
    user.admin?
  end

  def unlock?
    user.admin?
  end
end
