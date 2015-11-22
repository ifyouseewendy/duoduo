class EngineeringSalaryTablePolicy < EngineeringPolicy
  def edit?
    raise Pundit::NotAuthorizedError, "unauditied"\
      unless user.finance_admin? or pass_audition
  end

  def update?
    raise Pundit::NotAuthorizedError, "unauditied"\
      unless user.finance_admin? or pass_audition
  end

  def destroy?
    raise Pundit::NotAuthorizedError, "unauditied"\
      unless user.finance_admin? or pass_audition
  end

  private

    def pass_audition
      audition = record.audition
      audition.nil? or audition.init? or audition.history?
    end
end
