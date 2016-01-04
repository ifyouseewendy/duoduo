ActiveAdmin.register EngineeringSalaryTable do
  belongs_to :engineering_project, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 5

  index do
    selectable_column

    column :name
    column :type, sortable: :updated_at do |obj|
      obj.model_name.human.gsub('工资表', '')
    end
    column :start_date
    column :end_date
    column :project, sortable: :engineering_project_id do |obj|
      project = obj.project
      link_to project.name, "/engineering_projects?utf8=✓&q%5Bid_equals%5D=#{project.id}&commit=过滤"
    end
    column :remark
    column :created_at
    column :updated_at

    # column :audition_status, sortable: :id

    column :salary_item_detail, sortable: :updated_at do |obj|
      parts = obj.class.name.underscore.pluralize.split('_')
      parts[-1] = parts[-1].sub('table', 'item')
      path = parts.join('_')

      project_id = obj.project.id

      ul do
        li( link_to "查看", "/#{path}?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.id}&commit=过滤", target: '_blank' )
        li( link_to "导入", "/#{path}/import_new?engineering_salary_table_id=#{obj.id}", target: '_blank' )
        li( link_to "添加", "/#{path}/new?project_id=#{project_id}&salary_table_id=#{obj.id}", target: "_blank" )
      end
    end

    actions defaults: false do |obj|
      item "查看", engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "编辑", edit_engineering_salary_table_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "删除", engineering_salary_table_path(obj), method: :delete

      # text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #
      # item "发票",  "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{obj.id}&invoicable_type%5D=#{obj.class.name}&commit=过滤&order=id_desc"

      # if current_admin_user.finance_admin?
      #   if obj.audition.try(:already_audit?)
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "解除复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=init"
      #   else
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "确认复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=already_audit"
      #   end
      # elsif current_admin_user.finance_normal?
      #   if obj.audition.nil? or obj.audition.try(:init?)
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "申请复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=apply_audit"
      #   end
      # end
    end
  end

  # filter :project, as: :select, collection: ->{ EngineeringProject.as_filter }.call
  filter :name
  filter :type, as: :select, collection: ->{ EngineeringSalaryTable.types.map{|ty| [ty.model_name.human, ty.to_s]} }.call
  filter :start_date
  filter :end_date
  preserve_default_filters!
  remove_filter :audition
  remove_filter :reference
  remove_filter :project

  permit_params *( @resource.ordered_columns(without_base_keys: true, without_foreign_keys: false) )

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      if request.url.split('/')[-1] == 'new'
        f.input :type, as: :radio, collection: ->{ EngineeringSalaryTable.new_record_types.map{|k| [k.model_name.human, k.to_s]} }.call
      end
      f.input :start_date, as: :datepicker, hint: '请确保在项目的起止日期内'
      f.input :end_date, as: :datepicker, hint: '请确保在项目的起止日期内'
      f.input :project, collection: ->{ EngineeringProject.as_filter }.call
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
      row :project do |obj|
        link_to obj.project.name, engineering_project_path(obj.project)
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
