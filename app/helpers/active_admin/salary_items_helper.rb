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

  def present_fields(records, options = {})
    fields = SalaryItem.columns_based_on(view: options[:view], custom: options[:custom])
    fields.select do |key|
      records.map{|obj| obj.send(key)}.any? do |val|
        if Numeric === val
          val.nonzero?
        else
          val.present?
        end
      end
    end
  end

end
