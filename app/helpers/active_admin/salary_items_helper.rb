module ActiveAdmin::SalaryItemsHelper
  def salary_table
    @_salary_table ||= SalaryTable.find(params[:salary_table_id])
  end

  def normal_corporation
    @_normal_corporation ||= salary_table.normal_corporation
  end
end
