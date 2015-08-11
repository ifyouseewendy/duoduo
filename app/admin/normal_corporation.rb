ActiveAdmin.register NormalCorporation do
  menu \
    parent: I18n.t("activerecord.models.corporation")

  permit_params NormalCorporation.column_names - %w(id created_at updated_at)

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

end
