ActiveAdmin.register NormalCorporation do
  include ImportDemo

  active_admin_import \
    validate: true,
    template: 'import' ,
    batch_transaction: true,
    template_object: ActiveAdminImport::Model.new(
      csv_options: {col_sep: ",", row_sep: nil, quote_char: nil},
      csv_headers: @resource.ordered_columns(without_base_keys: true, without_foreign_keys: true),
      force_encoding: :auto,
      allow_archive: false,
  )

  menu \
    parent: I18n.t("activerecord.models.corporation"),
    priority: 21

  permit_params *NormalCorporation.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  index do
    selectable_column
    NormalCorporation.ordered_columns(without_foreign_keys: true).map do |field|
      if field == :admin_charge_type
        # enum
        column :admin_charge_type do |obj|
          obj.admin_charge_type_i18n
        end
      else
        column field
      end
    end
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :sub_companies, as: :check_boxes
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
      f.input :admin_charge_type, as: :radio, collection: NormalCorporation.admin_charge_types_option
      f.input :admin_charge_amount, as: :number
      f.input :expense_date, as: :datepicker
      f.input :stuff_count, as: :number
      f.input :insurance_count, as: :number
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      NormalCorporation.ordered_columns(without_foreign_keys: true).map do|field|
        if field == :admin_charge_type
          row :admin_charge_type do |obj|
            obj.admin_charge_type_i18n
          end
        else
          row field
        end
      end
      row :sub_companies do |corp|
        corp.sub_company_names.join(', ')
      end
    end

    panel "业务代理合同" do
      tabs do
        resource.sub_companies.each do |comp|
          tab comp.name do
            render partial: "shared/contract", locals: {sub_company: comp, corporation: resource}
          end
        end
      end
    end

    active_admin_comments
  end

end
