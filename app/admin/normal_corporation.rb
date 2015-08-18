ActiveAdmin.register NormalCorporation do
  # include ImportDemo
  #
  # active_admin_import \
  #   validate: true,
  #   template: 'import' ,
  #   batch_transaction: true,
  #   template_object: ActiveAdminImport::Model.new(
  #     csv_options: {col_sep: ",", row_sep: nil, quote_char: nil},
  #     csv_headers: @resource.ordered_columns,
  #     force_encoding: :auto,
  #     allow_archive: false,
  # )

  menu \
    parent: I18n.t("activerecord.models.corporation"),
    priority: 21

  # permit_params NormalCorporation.ordered_columns

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  scope "最近7天更新" do |record|
    record.updated_in_7_days
  end

  # index do
  #   selectable_column
  #   NormalCorporation.ordered_columns(all: true).map{|field| column field}
  #   actions
  # end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :name, as: :string
      f.input :license, as: :string
      f.input :taxpayer_serial, as: :string
      f.input :organization_serial, as: :string
      f.input :corporate_name, as: :string
      f.input :address, as: :string
      f.input :account, as: :string
      f.input :account_bank, as: :string
      f.input :contact, as: :string
      f.input :telephone, as: :phone
      f.input :contract_due_time, as: :datepicker
      f.input :contract_amount, as: :number
      f.input :admin_charge_type, as: :radio, collection: Rails.application.secrets.admin_charge_type.map{|n| I18n.t("misc.admin_charge_type.#{n}")}
      f.input :admin_charge_amount, as: :number
      f.input :expense_date, as: :datepicker
      f.input :stuff_count, as: :number
      f.input :insurance_count, as: :number
      f.input :jiyi_company_name, as: :radio, collection: Rails.application.secrets.jiyi_company_names
      f.input :remark, as: :text
    end

    f.actions
  end

  preserve_default_filters!
  filter :jiyi_company_name, as: :select, collection: proc { Rails.application.secrets.jiyi_company_names }

  # collection_action :import_csv, method: :post do
  #   # Do some CSV importing work here...
  #   redirect_to collection_path, notice: "CSV imported successfully!"
  # end
  #
  # action_item :import do
  #   link_to I18n.t("misc.import") + I18n.t("activerecord.models.normal_corporation"), import_csv_normal_corporations_path, method: :post
  # end
end
