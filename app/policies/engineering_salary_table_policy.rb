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

  private

    def pass_audition
      audition = record.audition
      audition.nil? or audition.init? or audition.history?
    end
end
