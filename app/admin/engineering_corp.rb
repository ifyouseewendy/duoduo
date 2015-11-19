ActiveAdmin.register EngineeringCorp do
  # include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 3

  preserve_default_filters!
  remove_filter :engineering_projects
  remove_filter :contract_files

  show do
    attributes_table do
      EngineeringCorp.ordered_columns(without_foreign_keys: true).map do |field|
        row field
      end
    end

    panel "业务代理合同" do
      tabs do
        # TODO
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
