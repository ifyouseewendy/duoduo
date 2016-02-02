ActiveAdmin.register NormalCorporation do
  # include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 1

  scope "全部" do |record|
    record.all
  end
  scope "存档" do |record|
    record.archive
  end
  scope "活动" do |record|
    record.active
  end

  config.sort_order = 'status_asc,updated_at_desc'

  # scope "最近10条更新" do |record|
  #   record.updated_latest_10
  # end

  index row_class: ->elem { 'due_date' if elem.due? } do
    selectable_column

    column :id
    column :name
    column :sub_company, sortable: :sub_company_id do |obj|
      sc = obj.sub_company
      link_to sc.name, "/sub_companies/#{sc.id}", target: '_blank'
    end
    column :normal_staffs, sortable: :id do |obj|
      link_to "员工列表", "/normal_staffs?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank'
    end
    column :labor_contracts, sortable: :id do |obj|
      link_to "劳务合同", "/labor_contracts?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank'
    end
    column :salary_table_display, sortable: :id do |obj|
      ul do
        if obj.salary_tables.count > 0
          li link_to("基础工资表", "/salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
        end
        if obj.guard_salary_tables.count > 0
          li link_to(" 保安工资表", "/guard_salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
        end
        if obj.non_full_day_salary_tables.count > 0
          li link_to(" 非全日制工资表", "/non_full_day_salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
        end
      end
    end

    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end
    column :admin_charge_type do |obj|
      obj.admin_charge_type_i18n
    end
    column :admin_charge_amount
    column :expense_date
    column :contract_start_date
    column :contract_end_date
    column :remark
    column :updated_at

    actions
  end

  filter :status, as: :check_boxes, collection: ->{ NormalCorporation.statuses_option(filter: true) }
  filter :id
  filter :name
  filter :sub_company
  filter :admin_charge_type, as: :select, collection: ->{ NormalCorporation.admin_charge_types_option(filter: true) }
  filter :admin_charge_amount
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
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      f.input :sub_company
      f.input :status, as: :radio, collection: ->{ NormalCorporation.statuses_option }.call
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
      row :sub_company do |obj|
        sc = obj.sub_company
        link_to sc.name, "/sub_companies/#{sc.id}", target: '_blank'
      end
      row :normal_staffs do |obj|
        link_to "员工列表", "/normal_staffs?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank'
      end
      row :labor_contracts do |obj|
        link_to "劳务合同", "/labor_contracts?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank'
      end
      row :salary_table_display do |obj|
        ul do
          if obj.salary_tables.count > 0
            li link_to("基础工资表", "/salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
          end
          if obj.guard_salary_tables.count > 0
            li link_to(" 保安工资表", "/guard_salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
          end
          if obj.non_full_day_salary_tables.count > 0
            li link_to(" 非全日制工资表", "/non_full_day_salary_tables?q[normal_corporation_id_eq]=#{obj.id}", target: '_blank' )
          end
        end
      end
      row :status do |obj|
        status_tag obj.status_i18n, (obj.active? ? :yes : :no)
      end
      row :admin_charge_type do |obj|
        obj.admin_charge_type_i18n
      end
      row :admin_charge_amount
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
        li link_to '基础工资表', normal_corporation_salary_tables_path(normal_corporation)
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

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => _
        failed << "操作失败<#{obj.name}>: #{obj.errors.full_messages.join(', ')}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = NormalCorporation.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :display do
    names, full_names = [], []
    NormalCorporation\
      .where(sub_company_id: params[:sub_company_id])\
      .includes(:sub_company)\
      .select(:sub_company_id, :name, :full_name)\
      .sort_by(&:name)\
      .each do |nc|
        name = nc.name
        # name = "#{nc.sub_company.name} - #{nc.name}" if nc.sub_company.present?

        names << name
        full_names << nc.full_name
      end

    render json: {status: 'ok', data: { names: names, full_names: full_names } }
  end

  collection_action :query_salary_tables do
    corp = NormalCorporation.where(name: params[:name]).first

    names, ids, types = [], [], []
    if corp.present?
      corp.salary_tables.order(start_date: :desc).each do |st|
        names << "基础 - #{st.name}"
        types << 'SalaryTable'
        ids << st.id
      end

      corp.guard_salary_tables.order(start_date: :desc).each do |st|
        names << "保安 - #{st.name}"
        types << 'GuardSalaryTable'
        ids << st.id
      end

      corp.non_full_day_salary_tables.order(start_date: :desc).each do |st|
        names << "非全日制 - #{st.name}"
        types << 'NonFullDaySalaryTable'
        ids << st.id
      end
    end

    render json: { status: :ok, data: {names: names, ids: ids, types: types } }
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:sub_company)
    end
  end
end
