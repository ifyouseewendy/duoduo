class EngineeringSalaryTablePolicy < EngineeringPolicy
  def edit?
    user.finance_admin? or pass_audition
  end

  def update?
    user.finance_admin? or pass_audition
  end

  def destroy?
    user.finance_admin? or pass_audition
  end

  class Scope < Scope
    def resolve
      scope.includes(:project).where(engineering_projects: {sub_company_id: user.visible_sub_company_ids})
    end
  end

  private

    def pass_audition
      audition = record.audition
      audition.nil? or !audition.already_audit
    end
end
