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

    column :audition_status, sortable: :id

    actions defaults: false do |obj|
      item "查看", engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "编辑", edit_engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "删除", engineering_salary_table_path(obj), method: :delete

      text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe

      item "发票",  "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{obj.id}&invoicable_type%5D=#{obj.class.name}&commit=过滤&order=id_desc"
      text_node "&nbsp;&nbsp;".html_safe

      parts = obj.class.name.underscore.pluralize.split('_')
      parts[-1] = parts[-1].sub('table', 'item')
      path = parts.join('_')
      item "工资条", "/#{path}?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
  end

  preserve_default_filters!
  remove_filter :reference

  permit_params *EngineeringSalaryTable.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :engineering_project, collection: EngineeringProject.all
      f.input :name, as: :string
      if request.url.split('/')[-1] == 'new'
        f.input :type, as: :radio, collection: EngineeringSalaryTable.types.map{|k| [k.model_name.human, k.to_s]}
      end
      if resource.type == 'EngineeringBigTableSalaryTable'
        f.input :url, as: :string
      end
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :engineering_project do |obj|
        link_to obj.engineering_project.name, engineering_project_path(obj.engineering_project)
      end
      row :type do |obj|
        obj.model_name.human
      end
      if resource.type == 'EngineeringBigTableSalaryTable'
        row :url do |obj|
          obj.url
        end
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

      if obj.type == 'EngineeringBigTableSalaryTable'
        obj.update_reference_url(params[:engineering_salary_table][:url])
      else
        obj.update! attrs
      end
      redirect_to engineering_salary_table_path(obj), notice: "成功更新工资表<#{obj.name}>"
    rescue => e
      redirect_to engineering_salary_table_path(obj), alert: "更新失败，#{e.message}"
    end
  end

end
