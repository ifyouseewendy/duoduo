ActiveAdmin.register SalaryTable do
  belongs_to :normal_corporation, optional: true

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 4

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

  config.sort_order = 'start_date_desc'

  index do
    selectable_column
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

    column :remark

    column :salary_items_display, sortable: :start_date do |obj|
      ul do
        li( link_to "工资条", salary_table_salary_items_path(obj), target: '_blank' )
        li( link_to "导入", "/salary_items/import_new?salary_table_id=#{obj.id}", target: '_blank' )
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

  filter :start_date, as: :select, collection: -> { SalaryTable.dates_as_filter }
  filter :name
  filter :normal_corporation, as: :select, collection: -> { NormalCorporation.as_filter }
  filter :status, as: :check_boxes, collection: ->{ SalaryTable.statuses_option(filter: true) }
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
      f.input :status, as: :check_boxes, collection: ->{ SalaryTable.statuses_option }.call
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

      row :salary_items do |obj|
        link_to '工资条', '#'
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
  batch_action :batch_edit, form: ->{ SalaryTable.batch_form_fields } do |ids|
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

  controller do
    def scoped_collection
      end_of_association_chain.includes(:normal_corporation)
    end
  end
end
