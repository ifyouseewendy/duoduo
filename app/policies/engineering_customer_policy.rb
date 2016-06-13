class EngineeringCustomerPolicy < EngineeringPolicy
  class Scope < Scope
    def resolve
      scope.includes(:projects).where(engineering_projects: {sub_company_id: user.visible_sub_company_ids})
    end
  end
end
