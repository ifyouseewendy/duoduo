ActiveAdmin.register Invoice do
  menu \
    parent: I18n.t("activerecord.models.invoice"),
    priority: 1

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
  scope "工程" do |record|
    record.engineer
  end
  scope "业务" do |record|
    record.business
  end
  scope "正常" do |record|
    record.work
  end
  scope "红充" do |record|
    record.red
  end
  scope "作废" do |record|
    record.cancel
  end

  index do
    selectable_column

    column :sub_company_name
    column :category, sortable: :category do |obj|
      status_tag obj.category_i18n, obj.category_tag
    end
    column :status, sortable: :status do |obj|
      status_tag obj.status_i18n, obj.status_tag
    end
    column :date
    column :code
    column :encoding
    column :scope, sortable: :scope do |obj|
      obj.scope_i18n
    end
    column :payer
    column :amount
    column :admin_amount
    column :total_amount
    column :contact
    column :income_date
    column :refund_date
    column :refund_person
    column :remark
    column :created_at
    column :updated_at

    actions
  end

  filter :sub_company_name, as: :select, collection: -> { SubCompany.pluck(:name) }
  filter :category, as: :select, collection: -> { resource_class.categories_option(filter: true) }
  filter :status, as: :select, collection: -> { resource_class.statuses_option(filter: true) }
  filter :scope, as: :select, collection: -> { resource_class.scopes_option(filter: true) }
  preserve_default_filters!
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :sub_company_name, as: :select, collection: -> { SubCompany.pluck(:name) }.call
      f.input :category, as: :radio, collection: ->{ resource_class.categories_option }.call
      f.input :status, as: :radio, collection: ->{ resource_class.statuses_option }.call
      f.input :date, as: :datepicker
      f.input :code, as: :string
      f.input :encoding, as: :string
      f.input :scope, as: :radio, collection: ->{ resource_class.scopes_option }.call
      f.input :amount, as: :number
      f.input :admin_amount, as: :number
      f.input :contact, as: :select, collection: []
      f.input :payer, as: :string
      f.input :income_date, as: :datepicker
      f.input :refund_date, as: :datepicker
      f.input :refund_person, as: :string
      f.input :remark, as: :text
      f.input :invoice_setting_id, as: :hidden
    end

    f.actions
  end

  show do
    attributes_table do
      row :sub_company_name
      row :category do |obj|
        status_tag obj.category_i18n, obj.category_tag
      end
      row :status do |obj|
        status_tag obj.status_i18n, obj.status_tag
      end
      row :date
      row :code
      row :encoding
      row :scope do |obj|
        obj.scope_i18n
      end
      row :payer
      row :amount
      row :admin_amount
      row :total_amount
      row :contact
      row :income_date
      row :refund_date
      row :refund_person
      row :remark
      row :created_at
      row :updated_at

    end

    active_admin_comments
  end


  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options.update(params[:q]) if params[:q].present?

    file = Invoice.export_xlsx(options: options)
    send_file file, filename: file.basename
  end
end
