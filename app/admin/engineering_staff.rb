ActiveAdmin.register EngineeringStaff do
  belongs_to :engineering_customer, optional: true
  include ImportSupport

  # Config
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 4

  # Index
  scope "全部" do |record|
    record.all
  end
  scope "可用" do |record|
    record.enabled
  end

  config.sort_order = 'updated_at_desc'

  index do
    selectable_column

    column :identity_card
    column :name
    column :enable, sortable: :enable do |obj|
      if obj.enable
        status_tag '可用', :yes
      else
        status_tag '不可用', :no
      end
    end
    column :customer, sortable: :id do |obj|
      link_to obj.customer.display_name, engineering_customer_path(obj.customer)
    end
    column :projects, sortable: :id do |obj|
      link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bengineering_staffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :salary_item_detail, sortable: :updated_at do |obj|
      stats = []
      if obj.engineering_normal_salary_items.count > 0
        stats << ["基础", "/engineering_normal_salary_items?utf8=✓&q%5Bstaff_id_eq%5D=#{obj.id}&commit=过滤"]
      end
      if obj.engineering_normal_with_tax_salary_items.count > 0
        stats << ["基础（带个税）", "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bstaff_id_eq%5D=#{obj.id}&commit=过滤"]
      end
      ul do
        stats.each do |ar|
          li( link_to ar[0], ar[1] )
        end
      end
    end

    (resource_class.ordered_columns(without_foreign_keys: true) - [:identity_card, :name, :id, :enable, :alias_name]).map(&:to_sym).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      else
        column field
      end
    end

    column :seal_index, sortable: :id do |obj|
      obj.seal_index
    end

    actions do |obj|
      # text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      # item "加入项目", "#", class: "add_projects_link expand_table_action_width"
      # text_node "&nbsp;&nbsp;".html_safe
      # item "离开项目", "#", class: "remove_projects_link"
    end
  end

  filter :identity_card
  filter :name
  filter :enable
  preserve_default_filters!
  remove_filter :salary_items
  remove_filter :engineering_normal_salary_items
  remove_filter :engineering_normal_with_tax_salary_items
  remove_filter :engineering_big_table_salary_items
  remove_filter :engineering_dong_fang_salary_items
  remove_filter :alias_name
  remove_filter :customer
  remove_filter :projects
  # filter :customer
  # filter :projects, as: :select, collection: ->{ EngineeringProject.as_filter }

  permit_params {
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) + [engineering_project_ids: []]
  }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :identity_card, as: :string
      f.input :name, as: :string
      f.input :enable
      f.input :customer
      f.input :projects, as: :select, collection: ->{ EngineeringProject.includes(:customer).map{|ep| ["#{ep.customer.display_name} - #{ep.display_name}", ep.id] } }.call
      f.input :birth, as: :datepicker
      f.input :gender, as: :radio, collection: ->{ EngineeringStaff.genders_option }.call
      f.input :nation, as: :string
      f.input :address, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  # member_action :update, method: :post do
  #   attrs = params.require(:engineering_staff).permit( EngineeringStaff.ordered_columns + [engineering_project_ids: []] )
  #
  #   begin
  #     obj = EngineeringStaff.find(params[:id])
  #     obj.update! attrs
  #
  #     redirect_to engineering_staff_path(obj), notice: "成功更新工程员工信息"
  #   rescue => e
  #     if e.message == "Staff refuse the project schedule"
  #       alert = "更新失败，多个工程项目的起止日期有重叠。"
  #       projects = params[:engineering_staff][:engineering_project_ids].map{|id| EngineeringProject.where(id: id).first }.reject(&:blank?)
  #       alert += projects.map{|pr| pr.range_output}.join('；')
  #     else
  #       alert = e.message
  #     end
  #     redirect_to engineering_staff_path(obj), alert: alert
  #   end
  # end

  show do
    attributes_table do
      row :identity_card
      row :name
      row :enable, sortable: :enable do |obj|
        if obj.enable
          status_tag '可用', :yes
        else
          status_tag '不可用', :no
        end
      end
      row :customer do |obj|
        link_to obj.customer.display_name, engineering_customer_path(obj.customer)
      end
      row :projects do |obj|
        link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bengineering_staffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
      end

      boolean_columns = resource.class.columns_of(:boolean)
      (resource.class.ordered_columns(without_foreign_keys: true) - [:id, :identity_card, :name, :enable, :alias_name]).map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          if field == :gender
            row :gender do |obj|
              obj.gender_i18n
            end
          else
            row field
          end
        end
      end

      row :seal_index do |obj|
        obj.seal_index
      end

    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringStaff.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  batch_action :assign_project, form: ->{
      {'engineering_project_id_工程项目' => EngineeringProject.id_name_option}
    } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access
    project = EngineeringProject.find(inputs[:engineering_project_id])

    messages = []
    failed = false
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.projects << project
        messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
      rescue => e
        failed = true
        messages << "操作失败，#{e.message}"
      end
    end

    if failed
      redirect_to :back, alert: messages.join('；')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options.update(params[:q])

    file = EngineeringStaff.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :query_free do
    project = EngineeringProject.find( params[:project_id] )

    customer = project.customer
    start_date, end_date = project.range
    own_staffs = customer.free_staffs(start_date, end_date, exclude_project_id: project.id)

    stats = {
      count: own_staffs.count,
      customer: customer.display_name,
      range_output: project.range_output,
      display_name: project.display_name
    }
    stats[:stat] = own_staffs.reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end
    render json: stats
  end

  collection_action :query_project do
    project = EngineeringProject.find( params[:project_id] )

    stats = project.staffs.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end

  # Member actions
  member_action :add_projects, method: :post do
    staff = EngineeringStaff.find(params[:id])
    projects = params[:engineering_project_ids].map{|id| EngineeringProject.where(id: id).first}.compact

    messages = []
    projects.each do |project|
      begin
        staff.projects << project
        messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  member_action :remove_projects, method: :post do
    staff = EngineeringStaff.find(params[:id])
    project_ids = staff.projects.select(:id).map(&:id) - (params[:engineering_project_ids].reject(&:blank?).map(&:to_i) rescue [])
    projects =  project_ids.map{|id| EngineeringProject.where(id: id).first}.compact

    messages = []
    projects.each do |project|
      begin
        staff.projects.delete project
        messages << "操作成功，员工<#{staff.name}>已离开项目<#{project.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end
end
