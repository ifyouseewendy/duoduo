class AdminUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.is_super_admin?
        scope
      elsif user.is_finance_admin?
        scope.finance
      elsif user.is_business_admin?
        scope.business
      end
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

  def update?
    user.admin? or user.id == record.id
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
