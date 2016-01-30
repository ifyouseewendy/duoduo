ActiveAdmin.register Invoice do
  menu \
    parent: I18n.t("activerecord.models.invoice"),
    priority: 1

  config.per_page = 30

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
  scope "存档" do |record|
    record.archive
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
    column :project, sortable: [:project_type, :project_id] do |obj|
      pr = obj.project
      if pr.present?
        link_to pr.try(:display_name), "#{pr.class.name.underscore.pluralize}?q[id_eq]=#{pr.id}", target: '_blank'
      else
      end
    end
    column :payer
    column :management
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
      item "查看", "/invoices/#{obj.id}"
      unless obj.archive?
        text_node "&nbsp;&nbsp;".html_safe
        item "编辑", "/invoices/#{obj.id}/edit"
      end
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
      else
        f.input :sub_company, as: :select, input_html: {disabled: true}
        f.input :category, as: :radio, collection: ->{ resource_class.categories_option }.call, input_html: {disabled: true}
        f.input :code, as: :string, input_html: {disabled: true}
        f.input :encoding, as: :string, input_html: {disabled: true}
      end
      if request.url.split('/')[-1] == 'new'
        f.input :date, as: :datepicker, input_html: { value: Date.today.to_s }
      else
        f.input :date, as: :datepicker
      end
      f.input :status, as: :radio, collection: ->{ resource_class.statuses_option }.call
      f.input :scope, as: :radio, collection: ->{ resource_class.scopes_option}.call
      if request.url.split('/')[-1] == 'new'
        f.input :contact, as: :select, collection: []
        f.input :project_id, as: :select, collection: []
      else
        f.input :contact, as: :select, collection: [ resource.contact ]
        f.input :project_id, as: :select, collection: [ [ resource.project.try(:display_name), resource.project_id ] ]
      end
      f.input :project_type, as: :hidden
      f.input :payer, as: :string
      f.input :management, as: :string
      f.input :amount, as: :number, hint: '批量创建时无须填写'
      f.input :admin_amount, as: :number, hint: '批量创建时无须填写'
      f.input :total_amount, as: :number, input_html: {disabled: true}, hint: '批量创建时无须填写'
      f.input :income_date, as: :datepicker
      f.input :refund_date, as: :datepicker
      f.input :refund_person, as: :string, hint: '批量创建时无须填写'
      f.input :remark, as: :string
      f.input :invoice_setting_id, as: :hidden
      if request.url.split('/')[-1] == 'new'
        f.input :batch_create, as: :boolean
        f.input :batch_count, as: :number
        f.input :batch_file, as: :file, hint: '请上传四列信息，劳务费，管理费，回款人，项目名称（只支持工程项目编号）'
      end
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
      row :project do |obj|
        link_to obj.project.try(:name), '#'
      end
      row :payer
      row :management
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
    attrs = attrs.except(:invoice_setting_id, :batch_create, :batch_count, :batch_file)

    begin
      is = InvoiceSetting.where( id: params[:invoice][:invoice_setting_id] ).first
      raise "创建失败：已无可用类型的发票" if is.blank?

      if params[:invoice][:batch_create] == '1'
        # Batch create
        batch_count = params[:invoice][:batch_count].to_i
        raise "批量创建失败：请填写正确的的发票数量" if batch_count == 0

        available_count = is.available_count.to_i - is.used_count.to_i
        raise "批量创建失败：可用发票数量不足，当前<#{is.sub_company.name}><#{is.category_i18n}>只剩下 #{available_count} 张" \
          if batch_count > available_count

        batch_file = params[:invoice][:batch_file]

        raise '批量创建失败：请选择上传文件' if batch_file.blank?
        raise '批量创建失败：请上传 xls(x) 类型的文件' \
          unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? batch_file.content_type

        xls = Roo::Spreadsheet.open(batch_file.path)
        sheet = xls.sheet(0)
        data = sheet.to_a.reject{|row| row.all?(&:blank?) }

        raise "批量创建失败：上传文件中行数为<#{data.count}>，与要创建发票数目<#{batch_count}>不相等" \
          if batch_count != data.count

        encoding = attrs[:encoding]
        is.class.transaction do
          data.each do |row|
            amount, admin_amount, refund_person, nest_index = row.map do |cell|
              if String === cell
                cell.strip
              else
                cell.to_f
              end
            end

            if attrs[:scope] == 'engineer'
              ec_nest_index = attrs[:contact].match(/^(\d+)/)[0] rescue nil
              customer = EngineeringCustomer.where(nest_index: ec_nest_index).first
              project = EngineeringProject.where(engineering_customer_id: customer.id, nest_index: nest_index).first
            else
              project = nil
            end
            Invoice.create! attrs.merge({encoding: encoding, amount: amount, admin_amount: admin_amount, refund_person: refund_person, project: project})
            is.increment_used!
            encoding = encoding.succ
          end
        end

        redirect_to '/invoices', notice: "成功批量创建#{batch_count}张发票，#{attrs[:encoding]} ~ #{is.last_encoding}"
      else
        Invoice.create! attrs

        is.increment_used!

        redirect_to '/invoices', notice: "成功创建发票 #{attrs[:encoding]}"
      end
    rescue => e
      redirect_to :back, alert: "#{e.message}"
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ Invoice.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => _
        failed << "操作失败发票编码<#{obj.encoding}>: #{obj.errors.full_messages.join(', ')}"
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
      end_of_association_chain.includes(:sub_company)
    end
  end
end
