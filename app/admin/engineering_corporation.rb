ActiveAdmin.register EngineeringCorporation do
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
    priority: 22

  permit_params *EngineeringCorporation.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  index do
    selectable_column
    EngineeringCorporation.ordered_columns(without_foreign_keys: true).map{|field| column field}
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :sub_companies, as: :check_boxes
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
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      boolean_columns = EngineeringCorporation.columns_of(:boolean)
      EngineeringCorporation.ordered_columns(without_foreign_keys: true).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
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

  sidebar '链接', only: [:show] do
    ul do
      li link_to EngineeringStaff.model_name.human, engineering_corporation_engineering_staffs_path(engineering_corporation)
      li link_to SalaryTable.model_name.human, '#'
    end
  end

  # Batch actions
  batch_action :batch_edit, form: EngineeringCorporation.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end
end
