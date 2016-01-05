ActiveAdmin.register EngineeringCustomer do
  # Config
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 1

  # Index
  config.sort_order = 'nest_index_desc'

  index do
    selectable_column

    column :nest_index
    column :name
    column :projects, sortable: :id do |obj|
      link_to "项目汇总", engineering_customer_engineering_projects_path(obj)
    end
    column :staffs, sortable: :id do |obj|
      link_to "提供人员", engineering_customer_engineering_staffs_path(obj) + "?q[customer_id_eq]=#{obj.id}"
    end
    column :sub_companies, sortable: :id do |obj|
      ul do
        obj.sub_companies.map do |sc|
          li link_to(sc.name, sub_company_path(sc))
        end
      end
    end
    (resource_class.ordered_columns - [:id, :nest_index, :name]).each do |field|
      column field
    end

    actions
  end

  filter :sub_company_in, as: :select, collection: ->{ SubCompany.hr.pluck(:name, :id) }
  filter :nest_index
  preserve_default_filters!
  remove_filter :projects
  remove_filter :staffs

  # New and Edit
  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :nest_index, as: :number, input_html: { :value => resource.nest_index || resource.class.available_nest_index }
      f.input :name, as: :string
      f.input :telephone, as: :string
      f.input :identity_card, as: :string
      f.input :bank_account, as: :string
      f.input :bank_name, as: :string
      f.input :bank_opening_place, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  # Show
  show do
    attributes_table do
      row :nest_index
      row :name
      row :projects do |obj|
        link_to "项目汇总", engineering_customer_engineering_projects_path(obj)
      end
      row :staffs do |obj|
        link_to "员工列表", engineering_customer_engineering_staffs_path(obj)
      end
      row :sub_companies, sortable: :id do |obj|
        ul do
          obj.sub_companies.map do |sc|
            li link_to(sc.name, sub_company_path(sc))
          end
        end
      end
      (resource_class.ordered_columns(without_foreign_keys: true) - [:id, :nest_index, :name]).map(&:to_sym).map do |field|
        row field
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringCustomer.batch_form_fields } do |ids|
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

    file = EngineeringCustomer.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :other_customers do
    project = EngineeringProject.find( params[:project_id] )
    customer = project.customer

    stats = EngineeringCustomer.where.not(id: customer.id).select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end

  member_action :free_staffs do
    customer = EngineeringCustomer.find( params[:id] )
    project = EngineeringProject.find( params[:project_id] )

    staffs = customer.free_staffs( *project.range )
    stats = staffs.reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end
end
