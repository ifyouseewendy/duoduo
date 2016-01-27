ActiveAdmin.register InvoiceSetting do
  menu \
    parent: I18n.t("activerecord.models.invoice"),
    priority: 2

  config.batch_actions = false

  scope "全部" do |record|
    record.all
  end
  scope "普通" do |record|
    record.normal
  end
  scope "增值税 A" do |record|
    record.vat_a
  end
  scope "增值税 B" do |record|
    record.vat_b
  end
  scope "可用" do |record|
    record.active
  end
  scope "已用完" do |record|
    record.archive
  end

  index do
    selectable_column

    column :sub_company

    column :category, sortable: :category do |obj|
      status_tag obj.category_i18n, obj.category_tag
    end

    column :code
    column :start_encoding
    column :end_encoding
    column :available_count
    column :used_count
    column :status, sortable: :status do |obj|
      status_tag obj.status_i18n, obj.status_tag
    end
    column :remark
    column :created_at
    column :updated_at

    actions
  end

  filter :sub_company, as: :select, collection: -> { SubCompany.pluck(:name, :id) }
  filter :category, as: :select, collection: -> { resource_class.categories_option(filter: true) }
  filter :code, as: :select, collection: -> { resource_class.select(:code).pluck(:code).uniq }
  filter :status, as: :select, collection: -> { resource_class.statuses_option(filter: true) }
  preserve_default_filters!
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      sub_company_collection = ->{
        SubCompany.all.each_with_index.reduce([]) do |ar, (sc,idx)|
          is = sc.last_invoice_setting
          html = {
            'data-category' => is[:category],
            'data-code' => is[:code]
          }
          if idx == 0
            html[:selected] = true
          end

          ar << [sc.name, sc.id, html]
        end
      }.call
      f.input :sub_company, as: :select, collection: sub_company_collection
      f.input :category, as: :radio, collection: ->{ resource_class.categories_option }.call
      f.input :code, as: :string
      f.input :start_encoding, as: :string
      f.input :available_count, as: :number
      f.input :status, as: :radio, collection: ->{ resource_class.statuses_option }.call
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :category do |obj|
        status_tag obj.category_i18n, obj.category_tag
      end

      row :code
      row :start_encoding
      row :available_count
      row :end_encoding
      row :status do |obj|
        status_tag obj.status_i18n, obj.status_tag
      end
      row :remark
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  collection_action :available do
    is = InvoiceSetting.available(params[:category]).first

    if is.blank?
      # category = InvoiceSetting.new(category: params[:category]).category_i18n
      render json: {status: 'failed', message: "已无该类型的发票可用，请到发票管理页添加"}
    else
      render json: {status: 'ok', data: { code: is.code, encoding: is.next_encoding, invoice_setting_id: is.id }}
    end
  end
end
