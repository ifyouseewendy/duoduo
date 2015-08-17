ActiveAdmin.register EngineeringCorporation do
  include ImportDemo

  active_admin_import \
    validate: true,
    template: 'import' ,
    batch_transaction: true,
    template_object: ActiveAdminImport::Model.new(
      csv_options: {col_sep: ",", row_sep: nil, quote_char: nil},
      csv_headers: @resource.csv_headers,
      force_encoding: :auto,
      allow_archive: false,
  )

  menu \
    parent: I18n.t("activerecord.models.corporation"),
    priority: 22

  permit_params EngineeringCorporation.column_names - %w(id created_at updated_at)

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  scope "最近7天更新" do |record|
    record.updated_in_7_days
  end

  index do
    selectable_column
    EngineeringCorporation.csv_headers(all: true).map{|field| column field}
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :main_index, as: :string
      f.input :nest_index, as: :string
      f.input :name, as: :string
      f.input :start_date, as: :datepicker
      f.input :project_date, as: :datepicker
      f.input :project_name, as: :string
      f.input :project_amount, as: :number
      f.input :admin_amount, as: :number
      f.input :total_amount, as: :number
      f.input :income_date, as: :datepicker
      f.input :income_amount, as: :number
      f.input :outcome_date, as: :datepicker
      f.input :outcome_referee, as: :string
      f.input :outcome_amount, as: :number
      f.input :proof, as: :string
      f.input :actual_project_amount, as: :number
      f.input :actual_admin_amount, as: :number
      f.input :already_get_contract, as: :boolean
      f.input :already_sign_dispatch, as: :boolean
      f.input :jiyi_company_name, as: :radio, collection: Rails.application.secrets.jiyi_company_names
      f.input :remark, as: :text
    end

    f.actions
  end

  preserve_default_filters!
  filter :jiyi_company_name, as: :select, collection: proc { Rails.application.secrets.jiyi_company_names }
end
