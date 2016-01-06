ActiveAdmin.register EngineeringCorp do
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 2

  index do
    selectable_column
    column :name
    column :contract_start_date
    column :contract_end_date
    column :remark
    column :created_at
    column :updated_at
    actions
  end

  filter :sub_company_in, as: :select, collection: ->{ SubCompany.hr.pluck(:name, :id) }
  preserve_default_filters!
  remove_filter :projects
  remove_filter :big_contracts
  remove_filter :sub_company

  permit_params :name

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      f.input :remark, as: :string
    end

    f.actions
  end

  show do
    attributes_table do
      EngineeringCorp.ordered_columns(without_foreign_keys: true).map do |field|
        row field
      end
    end

    panel "大协议" do
      render partial: 'engineering_corps/contract_list', \
        locals: { contract_files: resource.big_contracts }
      tabs do
        tab '手动上传' do
          render partial: "engineering_corps/contract_upload", \
            locals: {
              object: resource,
            }
        end
      end
    end

    active_admin_comments
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = EngineeringCorp.export_xlsx(options: options)
    send_file file, filename: file.basename
  end
end
