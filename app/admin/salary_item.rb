ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [salary_table.corporation.name, salary_table.name]
  end

  permit_params :staff_name, :salary_deserve, :salary_table_id

  form partial: 'form'

  controller do
    def create
      st = SalaryTable.find(params[:salary_table_id])
      name = permitted_params[:salary_item][:staff_name]
      salary = permitted_params[:salary_item][:salary_deserve].to_f

      begin
        SalaryItem.create_by(salary_table: st, name: name, salary: salary)

        redirect_to salary_table_salary_items_path(st), notice: "成功创建基础工资条"
      rescue => e
        redirect_to new_salary_table_salary_item_path(st), alert: "创建失败，#{e.message}"
      end
    end
  end
end
