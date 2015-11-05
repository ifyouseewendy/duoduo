ActiveAdmin.register EngineeringStaff do
  belongs_to :engineering_customer, optional: true
  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 4

  index do
    selectable_column

    column :id
    column :nest_index
    column :name
    column :engineering_customer, sortable: :id do |obj|
      link_to obj.engineering_customer.name, engineering_customer_path(obj.engineering_customer)
    end
    column :engineering_projects, sortable: :id do |obj|
      link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bengineering_staffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end

    (EngineeringStaff.ordered_columns(without_foreign_keys: true) - [:id, :nest_index, :name]).map(&:to_sym).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      else
        column field
      end
    end
    actions do |obj|
      text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      item "加入项目", "#", class: "add_project_link", data: { project_ids: [ EngineeringProject.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]} ] }
      text_node "&nbsp;&nbsp;".html_safe
      item "删除项目", "#", class: "remove_project_link"
    end
  end

  preserve_default_filters!
  remove_filter :salary_items

  permit_params *( EngineeringStaff.ordered_columns(without_base_keys: true, without_foreign_keys: false) + [engineering_project_ids: []] )

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :engineering_customer, collection: EngineeringCustomer.all
      # f.input :engineering_projects, as: :select, collection: EngineeringProject.all
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :identity_card, as: :string
      f.input :birth, as: :datepicker
      f.input :age, as: :number
      f.input :gender, as: :radio, collection: EngineeringStaff.genders_option
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
      row :id
      row :nest_index
      row :name
      row :engineering_customer do |obj|
        link_to obj.engineering_customer.name, engineering_customer_path(obj.engineering_customer)
      end
      row :engineering_projects do |obj|
        link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bengineering_staffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
      end

      boolean_columns = EngineeringStaff.columns_of(:boolean)
      (EngineeringStaff.ordered_columns(without_foreign_keys: true) - [:id, :nest_index, :name]).map(&:to_sym).map do |field|
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
    end
  end

  # Batch actions
  batch_action :batch_edit, form: EngineeringStaff.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  batch_action :assign_project, \
    form: {
      'engineering_project_id_工程项目' => EngineeringProject.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]}
    } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access
    project = EngineeringProject.find(inputs[:engineering_project_id])

    names = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.engineering_projects << project
      rescue => _
        names << obj.name
      end
    end

    if names.blank?
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    else
      redirect_to :back, alert: "更新失败（#{names.join(',')}），已分配项目与待分配项目时间重叠"
    end
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = EngineeringStaff.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  # Member actions
  member_action :add_project, method: :post do
    staff = EngineeringStaff.find(params[:id])
    project = EngineeringProject.find(params[:engineering_project_id])
    require'pry';binding.pry
    begin
      staff.engineering_projects << project
      render json: {message: '操作成功'}
    rescue => e
      render json: {message: "操作失败（#{e.message}）"}
    end
  end
end
