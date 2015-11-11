ActiveAdmin.register Invoice do
  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 7

  config.filters = false

  index do
    selectable_column

    Invoice.ordered_columns(without_foreign_keys: true).each do |field|
      column field
    end

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :release_date, as: :datepicker
      f.input :encoding, as: :string
      f.input :payer, as: :string
      f.input :project_name, as: :string
      f.input :amount, as: :number
      f.input :total_amount, as: :number
      f.input :contact_person, as: :string
      f.input :refund_person, as: :string
      f.input :refund_bank, as: :string
      f.input :refund_account, as: :string
      f.input :income_date, as: :datepicker
      f.input :refund_date, as: :datepicker
    end

    f.actions
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options[:salary_table_id] = params[:salary_table_id].to_i

    file = Invoice.export_xlsx(options: options)
    send_file file, filename: file.basename
  end
end
