module ActiveAdmin::SalaryItemsHelper
  def salary_table
    @salary_table ||= SalaryTable.find(params[:salary_table_id])
  end
end
