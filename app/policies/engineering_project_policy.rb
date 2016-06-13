class EngineeringProjectPolicy < EngineeringPolicy
  class Scope < Scope
    def resolve
      scope.where(sub_company_id: user.visible_sub_company_ids)
    end
  end
end
