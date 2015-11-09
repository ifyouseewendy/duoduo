ActiveAdmin.register EngineeringSalaryTable do
  belongs_to :engineering_project, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 5

  index do
    selectable_column

    column :id
    column :name
    column :type, sortable: :id do |obj|
      obj.model_name.human
    end
    column :engineering_project, sortable: :engineering_project_id do |obj|
      link_to obj.engineering_project.name, engineering_project_path(obj.engineering_project)
    end
    column :remark
    column :created_at
    column :updated_at

    actions defaults: false do |obj|
      item "查看", engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "编辑", edit_engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "删除", engineering_salary_table_path(obj), method: :delete

      text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      item "工资条", "#"
    end
  end

  permit_params *EngineeringSalaryTable.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :engineering_project, collection: EngineeringProject.all
      f.input :name, as: :string
      f.input :type, as: :radio, collection: EngineeringSalaryTable.types.map{|k| [k.model_name.human, k.to_s]}
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :type do |obj|
        obj.model_name.human
      end
      row :engineering_project do |obj|
        link_to obj.engineering_project.name, engineering_project_path(obj.engineering_project)
      end
      row :remark
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  member_action :update, method: :post do
    attrs = params.require(:engineering_salary_table).permit( EngineeringSalaryTable.ordered_columns )

    begin
      obj = EngineeringSalaryTable.find(params[:id])
      obj.update! attrs
      redirect_to engineering_salary_table_path(obj), notice: "成功更新工资表<#{obj.name}>"
    rescue => e
      redirect_to engineering_salary_table_path(obj), alert: "更新失败，#{e.message}"
    end
  end

end
