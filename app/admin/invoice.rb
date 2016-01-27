ActiveAdmin.register Invoice do
  menu \
    parent: I18n.t("activerecord.models.invoice"),
    priority: 1

  scope "全部" do |record|
    record.all
  end
  scope "通用机打发票" do |record|
    record.normal
  end
  scope "增值税普通" do |record|
    record.vat_a
  end
  scope "增值税专用" do |record|
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

    column :sub_company, sortable: :sub_company_id
    column :category, sortable: :category do |obj|
      status_tag obj.category_i18n, obj.category_tag
    end
    column :code
    column :encoding
    column :date
    column :status, sortable: :status do |obj|
      status_tag obj.status_i18n, obj.status_tag
    end
    column :scope, sortable: :scope do |obj|
      obj.scope_i18n
    end
    column :contact
    column :payer
    column :amount
    column :admin_amount
    column :total_amount
    column :income_date
    column :refund_date
    column :refund_person
    column :remark
    column :created_at
    column :updated_at

    actions defaults: false do |obj|
      item "查看", engineering_company_medical_insurance_amount_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "编辑", edit_engineering_company_medical_insurance_amount_path(obj)
    end
  end

  filter :sub_company, as: :select, collection: -> { SubCompany.pluck(:name, :id) }
  filter :category, as: :select, collection: -> { resource_class.categories_option(filter: true) }
  filter :status, as: :select, collection: -> { resource_class.statuses_option(filter: true) }
  filter :scope, as: :select, collection: -> { resource_class.scopes_option(filter: true) }
  preserve_default_filters!
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      if request.url.split('/')[-1] == 'new'
        sub_company_collection = ->{
          SubCompany.all.each_with_index.reduce([]) do |ar, (sc,idx)|
            is = sc.last_invoice_setting
            html = {
              'data-category' => is[:category],
              'data-code' => is[:code],
              'data-encoding' => is[:encoding],
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
        f.input :encoding, as: :string
      end
      f.input :date, as: :datepicker, input_html: { value: Date.today.to_s }
      f.input :status, as: :radio, collection: ->{ resource_class.statuses_option }.call
      f.input :scope, as: :radio, collection: ->{ resource_class.scopes_option }.call
      f.input :contact, as: :select, collection: []
      f.input :payer, as: :string
      f.input :amount, as: :number
      f.input :admin_amount, as: :number
      f.input :total_amount, as: :number, input_html: {disabled: true}
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
      row :sub_company
      row :category do |obj|
        status_tag obj.category_i18n, obj.category_tag
      end
      row :code
      row :encoding
      row :date
      row :status do |obj|
        status_tag obj.status_i18n, obj.status_tag
      end
      row :scope do |obj|
        obj.scope_i18n
      end
      row :contact
      row :payer
      row :amount
      row :admin_amount
      row :total_amount
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
  # collection_action :export_xlsx do
  #   options = {}
  #   options[:selected] = params[:selected].split('-') if params[:selected].present?
  #   options[:columns] = params[:columns].split('-') if params[:columns].present?
  #   options.update(params[:q]) if params[:q].present?
  #
  #   file = Invoice.export_xlsx(options: options)
  #   send_file file, filename: file.basename
  # end

  collection_action :create, method: :post do
    attrs = params.require(:invoice).permit( resource_class.ordered_columns )

    begin
      Invoice.create! attrs.except(:invoice_setting_id)

      is = InvoiceSetting.find( params[:invoice][:invoice_setting_id] )
      is.increment_used!

      redirect_to '/invoices', notice: '成功创建发票'
    rescue => e
      redirect_to :back, alert: "#{e.message}"
    end
  end
end
