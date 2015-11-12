ActiveAdmin.register EngineeringProject do
  belongs_to :engineering_customer, optional: true

  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 2

  index do
    selectable_column

    column :id
    column :name
    column :engineering_staffs, sortable: :id do |obj|
      link_to "员工列表", "/engineering_staffs?utf8=✓&q%5Bengineering_projects_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :engineering_customer, sortable: :id do |obj|
      link_to obj.engineering_customer.name, engineering_customer_path(obj.engineering_customer)
    end
    column :engineering_corp, sortable: :id do |obj|
      link_to obj.engineering_corp.name, engineering_corp_path(obj.engineering_corp)
    end
    (EngineeringProject.ordered_columns(without_foreign_keys: true) - [:id, :name]).each do |field|
      column field
    end

    actions do |obj|
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "添加员工", "#", class: "add_staffs_link"
      text_node "&nbsp;&nbsp;".html_safe
      item "删除员工", "#", class: "remove_staffs_link"

      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "生成工资表", "#", class: "generate_salary_table_link expand_table_action_width_large"
      text_node "&nbsp;&nbsp;".html_safe
      item "查看工资表", engineering_project_engineering_salary_tables_path(obj)
    end
  end

  preserve_default_filters!
  remove_filter :engineering_staffs
  remove_filter :engineering_salary_tables

  permit_params *EngineeringProject.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :engineering_customer, collection: EngineeringCustomer.all
      f.input :engineering_corp, collection: EngineeringCorp.all
      f.input :name, as: :string
      f.input :start_date, as: :datepicker
      f.input :project_start_date, as: :datepicker
      f.input :project_end_date, as: :datepicker
      f.input :project_range, as: :string
      f.input :project_amount, as: :number
      f.input :admin_amount, as: :number
      f.input :income_date, as: :datepicker
      f.input :income_amount, as: :number
      f.input :outcome_date, as: :datepicker
      f.input :outcome_referee, as: :string
      f.input :outcome_amount, as: :number
      f.input :proof, as: :string
      f.input :already_get_contract, as: :boolean
      f.input :already_sign_dispatch, as: :boolean
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :engineering_staffs do |obj|
        link_to "员工列表", "/engineering_staffs?utf8=✓&q%5Bengineering_projects_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
      end
      row :engineering_customer do |obj|
        link_to obj.engineering_customer.name, engineering_customer_path(obj.engineering_customer)
      end
      row :engineering_corp do |obj|
        link_to obj.engineering_corp.name, engineering_corp_path(obj.engineering_corp)
      end

      boolean_columns = EngineeringProject.columns_of(:boolean)
      (EngineeringProject.ordered_columns(without_foreign_keys: true) - [:id, :name]).map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          row field
        end
      end
    end

    panel "工程合同（劳务派遣协议）" do
      render partial: 'shared/contract_engineering', locals: { contract_files: resource.contract_files, engineering_project_id: resource.id, role: :normal }
    end
    active_admin_comments
  end

  # Batch actions
  batch_action :batch_edit, form: EngineeringProject.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = EngineeringProject.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :query_all do
    stats = EngineeringProject.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end
    render json: stats
  end

  collection_action :query_staff do
    staff = EngineeringStaff.find( params[:staff_id] )

    stats = staff.engineering_projects.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end

  # Member actions
  member_action :add_staffs, method: :post do
    project = EngineeringProject.find(params[:id])
    staffs = params[:engineering_staff_ids].map{|id| EngineeringStaff.where(id: id).first}.compact

    messages = []
    staffs.each do |staff|
      begin
        project.engineering_staffs << staff
        messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  member_action :remove_staffs, method: :post do
    project = EngineeringProject.find(params[:id])
    staff_ids = project.engineering_staffs.select(:id).map(&:id) - (params[:engineering_staff_ids].reject(&:blank?).map(&:to_i) rescue [])
    staffs =  staff_ids.map{|id| EngineeringStaff.where(id: id).first}.compact

    messages = []
    staffs.each do |staff|
      begin
        project.engineering_staffs.delete staff
        messages << "操作成功，员工<#{staff.name}>已离开项目<#{project.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  member_action :available_staff_count do
    project = EngineeringProject.find( params[:id] )
    own_staff_count = project.engineering_staffs.count

    customer = project.engineering_customer
    other_staff_count = customer.free_staffs( *project.range ).count

    render json: { count: own_staff_count + other_staff_count  }
  end

  member_action :generate_salary_table, method: :post do
    project = EngineeringProject.find(params[:id])

    begin
      if 'EngineeringNormalSalaryTable' == params[:salary_type]
        project.generate_salary_table(need_count: params[:need_count].to_i)
      elsif 'EngineeringNormalWithTaxSalaryTable' == params[:salary_type]
        project.generate_salary_table_with_tax(file: params[:salary_file])
      else
        project.generate_salary_table_big(url: params[:salary_url])
      end

      render json: {status: 'succeed', url: engineering_project_engineering_salary_tables_path(project) }
    rescue => e
      render json: {status: 'failed', message: e.message }
    end
  end

end
