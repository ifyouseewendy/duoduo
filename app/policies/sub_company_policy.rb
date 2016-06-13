class SubCompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(id: user.visible_sub_company_ids)
    end
  end
end
