class SubCompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.visible_sub_company_ids.blank?
        scope
      else
        scope.where(id: user.visible_sub_company_ids)
      end
    end
  end
end
