ActiveAdmin.register EngineeringBigTableSalaryItem do
  controller do
    def index
      id = params[:q][:salary_table_id_eq] rescue nil
      st = EngineeringSalaryTable.where(id: id).first
      if st && st.reference.try(:url)
        redirect_to st.reference.url
      else
        redirect_to :back, alert: "该大表类型工资表未添加可用链接"
      end
    end
  end
end
