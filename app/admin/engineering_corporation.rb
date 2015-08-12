ActiveAdmin.register EngineeringCorporation do
  menu \
    parent: I18n.t("activerecord.models.corporation"),
    priority: 22

  permit_params EngineeringCorporation.column_names - %w(id created_at updated_at)

  scope "最近七天更新" do |record|
    record.updated_in_7_days
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :nest_id, as: :string
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
