ActiveAdmin.register SalaryTable do
  belongs_to :normal_corporation, optional: true

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 4

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
      link_to nc.name, normal_corporation_path(nc)
    end
    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end

    column :remark

    actions do |st|
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "工资条", salary_table_salary_items_path(st), class: "member_link"
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      if st.lai_table.present?
        item '来表', st.lai_table.url
        text_node "&nbsp;".html_safe
      end
      if st.daka_table.present?
        item '打卡表', st.daka_table.url
      end
      # item "发票", "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{st.id}&invoicable_type%5D=#{st.class.name}&commit=过滤&order=id_desc", class: "member_link expand_table_action_width"
    end
  end

  filter :start_date, as: :select, collection: -> { SalaryTable.dates_as_filter }
  filter :name
  filter :normal_corporation, as: :select, collection: -> { NormalCorporation.as_filter }
  filter :status, as: :check_boxes, collection: ->{ SalaryTable.statuses_option }
  preserve_default_filters!
  remove_filter :invoices
  remove_filter :salary_items
  remove_filter :lai_table
  remove_filter :daka_table

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

end
