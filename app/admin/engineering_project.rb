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

    actions
  end

  preserve_default_filters!
  remove_filter :engineering_staffs

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
    render json: EngineeringProject.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]}.inspect.to_json
  end

  collection_action :query_staff do
    staff = EngineeringStaff.find( params[:staff_id] )

    projects = staff.engineering_projects.select(:id, :name)
    stats = {
      project_ids: projects.reduce({}){|ha, ele| ha[ele.id] = 'checkbox'; ha},
      names: projects.map(&:name)
    }

    render json: stats
  end
end
