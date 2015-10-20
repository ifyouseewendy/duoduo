module ActiveAdmin::SalaryItemsHelper
  def salary_table
    @_salary_table ||= SalaryTable.where(id: params[:salary_table_id]).first
  end

  def guard_salary_table
    @_guard_salary_table ||= GuardSalaryTable.where(id: params[:guard_salary_table_id]).first
  end

  def non_full_day_salary_table
    @_non_full_day_salary_table ||= NonFullDaySalaryTable.where(id: params[:non_full_day_salary_table_id]).first
  end

  def normal_corporation
    @_normal_corporation ||= [salary_table, guard_salary_table, non_full_day_salary_table].detect{|st| st.try(:normal_corporation)}
  end
end
