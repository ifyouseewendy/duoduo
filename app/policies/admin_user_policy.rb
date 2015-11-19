class AdminUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def demo?
    false
  end

  def reset_password?
    user.admin?
  end
end
