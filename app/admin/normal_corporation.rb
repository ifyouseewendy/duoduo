ActiveAdmin.register NormalCorporation do
  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 1

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true) }

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  index do
    selectable_column

    column :id
    column :name

    column :sub_company, sortable: :sub_company_id
    column :normal_staffs, sortable: :id do |obj|
      link_to "员工列表", normal_corporation_normal_staffs_path(obj)
    end

    # column :stuff_count, sortable: ->(obj){ obj.stuff_count }
    # column :stuff_has_insurance_count, sortable: ->(obj){ obj.stuff_has_insurance_count }

    # column :labor_contracts, sortable: :id do |obj|
    #   link_to "劳务合同列表", "/labor_contracts?utf8=✓&q%5Bnormal_corporation_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    # end

    column :salary_tables, sortable: :id do |obj|
      href = link_to("普通工资表", normal_corporation_salary_tables_path(obj) )
      href += link_to(" 保安工资表", normal_corporation_guard_salary_tables_path(obj) ) \
        if obj.guard_salary_tables.count > 0
      href += link_to(" 非全日制工资表", normal_corporation_non_full_day_salary_tables_path(obj) ) \
        if obj.non_full_day_salary_tables.count > 0

      href
    end

    column :admin_charge_type do |obj|
      obj.admin_charge_type_i18n
    end
    column :admin_charge_amount
    column :expense_date
    column :contract_start_date
    column :contract_end_date

    actions
  end

  preserve_default_filters!
  remove_filter :contract_files
  remove_filter :normal_staffs
  remove_filter :labor_contracts
  remove_filter :salary_tables
  remove_filter :salary_items
  remove_filter :guard_salary_tables
  remove_filter :guard_salary_items
  remove_filter :non_full_day_salary_tables
  remove_filter :non_full_day_salary_items

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :sub_company
      f.input :name, as: :string
      f.input :full_name, as: :string
      f.input :license, as: :string
      f.input :taxpayer_serial, as: :string
      f.input :organization_serial, as: :string
      f.input :corporate_name, as: :string
      f.input :address, as: :string
      f.input :account, as: :string
      f.input :account_bank, as: :string
      f.input :contact, as: :string
      f.input :telephone, as: :phone
      f.input :admin_charge_type, as: :radio, collection: ->{ NormalCorporation.admin_charge_types_option }.call
      f.input :admin_charge_amount, as: :number, hint: '比例值请填小数，例如 8% 请填 0.08'
      f.input :expense_date, as: :datepicker
      f.input :contract_amount, as: :number
      f.input :contract_start_date, as: :datepicker
      f.input :contract_end_date, as: :datepicker
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :sub_company
      row :full_name
      row :license
      row :taxpayer_serial
      row :organization_serial
      row :corporate_name
      row :address
      row :account
      row :account_bank
      row :contact
      row :telephone
      row :admin_charge_type do |obj|
        obj.admin_charge_type_i18n
      end
      row :admin_charge_amount
      row :expense_date
      row :contract_amount
      row :contract_start_date
      row :contract_end_date
      row :remark
      row :updated_at
      row :created_at
    end

    panel "业务代理合同" do
      render partial: "normal_corporations/contract_list", locals: {contract_files: resource.contract_files}
      render partial: "normal_corporations/contract_upload", locals: {resource: resource}
    end

    active_admin_comments
  end

  sidebar '链接', only: [:show] do
    ul do
      li link_to "员工列表", normal_corporation_normal_staffs_path(normal_corporation)
      if normal_corporation.salary_tables.count > 0
        li link_to '普通工资表', normal_corporation_salary_tables_path(normal_corporation)
      end
      if normal_corporation.guard_salary_tables.count > 0
        li link_to '保安工资表', normal_corporation_guard_salary_tables_path(normal_corporation)
      end
      if normal_corporation.non_full_day_salary_tables.count > 0
        li link_to '保安工资表', normal_corporation_non_full_day_salary_tables_path(normal_corporation)
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ NormalCorporation.batch_form_fields } do |ids|
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

    file = NormalCorporation.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:sub_company)
    end
  end
end
