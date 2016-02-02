ActiveAdmin.register GuardSalaryTable do
  belongs_to :normal_corporation, optional: true

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 5

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (ncid=params['q']['normal_corporation_id_eq']).present?
        nc = NormalCorporation.where(id: ncid).first
        if nc.present?
          crumbs << link_to('合作单位', "/normal_corporations")
          crumbs << link_to(nc.name, "/normal_corporations?q[id_eq]=#{nc.id}")
        end
      end
    elsif params[:action] == 'show'
      crumbs << link_to('保安工资表', "/guard_salary_tables")
    end

    crumbs
  end

  scope "全部" do |record|
    record.all
  end
  scope "存档" do |record|
    record.archive
  end
  scope "活动" do |record|
    record.active
  end

  config.sort_order = 'updated_at_desc'

  index has_footer: true do
    selectable_column

    sum_fields = resource_class.sum_fields
    sum = sum_fields.reduce({}) do |ha, field|
      ha[field] = collection.sum(field)
      ha
    end

    column :start_date, sortable: :start_date do |obj|
      obj.month
    end
    column :name
    column :normal_corporation, sortable: :normal_corporation_id do |obj|
      nc = obj.normal_corporation
      link_to nc.name, normal_corporation_path(nc), target: '_blank'
    end
    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end
    column :invoices, sortable: :id do |obj|
      if obj.invoices.present?
        if obj.has_equal_invoices?
          link_to '发票', "/invoices?q[project_type_eq]=GuardSalaryTable&&q[project_id_eq]=#{obj.id}", target: '_blank', class: 'invoice-valid'
        else
          link_to '发票', "/invoices?q[project_type_eq]=GuardSalaryTable&&q[project_id_eq]=#{obj.id}", target: '_blank', class: 'invoice-invalid'
        end
      end
    end
    column :amount, footer: sum[:amount]

    column :remark

    column :salary_items_display, sortable: :start_date do |obj|
      ul do
        li( link_to "工资条", "/guard_salary_tables/#{obj.id}/guard_salary_items", target: '_blank' )
        li( link_to "导入", "/guard_salary_items/import_new?guard_salary_table_id=#{obj.id}", target: '_blank' )
      end
    end

    column :attachment, sortable: :start_date do |obj|
      ul do
        if obj.lai_table.present?
          li( link_to '来表', obj.lai_table.url )
        end
        if obj.daka_table.present?
          li( link_to '打卡表', obj.daka_table.url )
        end
      end
    end

    actions do |st|
      # item "发票", "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{st.id}&invoicable_type%5D=#{st.class.name}&commit=过滤&order=id_desc", class: "member_link expand_table_action_width"
    end
  end

  filter :start_date, as: :select, collection: -> { GuardSalaryTable.dates_as_filter }
  filter :name
  filter :normal_corporation, as: :select, collection: -> { NormalCorporation.as_filter }
  filter :status, as: :check_boxes, collection: ->{ GuardSalaryTable.statuses_option(filter: true) }
  filter :amount
  preserve_default_filters!
  # remove_filter :invoices
  remove_filter :salary_items
  remove_filter :lai_table
  remove_filter :daka_table
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :start_date, as: :datepicker, hint: '请选择月份第一天代表该月。例如，9月工资表请选择9月1号'
      f.input :name, as: :string
      f.input :normal_corporation, as: :select, collection: -> { NormalCorporation.as_filter }.call
      f.input :status, as: :radio, collection: ->{ GuardSalaryTable.statuses_option }.call
      f.input :lai_table, as: :file
      f.input :daka_table, as: :file
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :start_date do |obj|
        obj.month
      end
      row :name
      row :normal_corporation do |obj|
        nc = obj.normal_corporation
        link_to nc.name, normal_corporation_path(nc)
      end
      row :status do |obj|
        status_tag obj.status_i18n, (obj.active? ? :yes : :no)
      end
      row :invoices do |obj|
        if obj.invoices.present?
          if obj.has_equal_invoices?
            link_to '发票', "/invoices?q[project_type_eq]=GuardSalaryTable&&q[project_id_eq]=#{obj.id}", target: '_blank', class: 'invoice-valid'
          else
            link_to '发票', "/invoices?q[project_type_eq]=GuardSalaryTable&&q[project_id_eq]=#{obj.id}", target: '_blank', class: 'invoice-invalid'
          end
        end
      end
      row :amount

      row :salary_items do |obj|
        link_to "工资条", guard_salary_table_guard_salary_items_path(obj), target: '_blank'
      end

      row :lai_table do |obj|
        link_to (obj.lai_table_identifier || '无'), (obj.lai_table.try(:url) || '#')
      end
      row :daka_table do |obj|
        link_to (obj.daka_table_identifier || '无'), (obj.daka_table.try(:url) || '#')
      end

      row :remark
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ GuardSalaryTable.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => _
        failed << "操作失败<编号#{obj.nest_index}>: #{obj.errors.full_messages.join(', ')}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  member_action :audition_state do
    st = GuardSalaryTable.find(params[:id])
    audition = st.audition
    display = st.audition_display

    admin = current_active_admin_user.admin?
    data = GuardSalaryTable::AUDITION_STAGE.reduce([]) do |ar, k|
      ar << {
        key: k,
        value: audition[k.to_s],
        display: display[k],
        hide: !admin
      }
    end
    render json: { status: :ok, data: data }
  end

  member_action :toggle_audition_state do
    st = GuardSalaryTable.find(params[:id])
    state = params[:state]

    st.audition[state.to_s.strip] = current_active_admin_user.name
    st.save!

    render json: { status: :ok, message: '操作成功' }
  end

  member_action :update_remark do
    st = GuardSalaryTable.find(params[:id])
    st.remark = params[:remark]
    st.save!
    render json: { status: :ok, message: '操作成功' }
  end

  controller do
    after_action :set_audition, only: :create

    def scoped_collection
      end_of_association_chain.includes(:normal_corporation)
    end

    def set_audition
      resource.audition[:make_table] = current_active_admin_user.name
      resource.save!
    end
  end
end
