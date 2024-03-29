ActiveAdmin.register EngineeringSalaryTable do
  belongs_to :engineering_project, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 5

  config.action_items.delete_if { |item|
    # item is an ActiveAdmin::ActionItem
    item.display_on?(:show) or item.display_on?(:index)
  }

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (pid=params['q']['project_id_eq']).present?
        project = EngineeringProject.where(id: pid).first
        if project.present?
          customer = project.customer
          if customer.present?
            crumbs << link_to(customer.display_name, "/engineering_customers?q[id_eq]=#{customer.id}")
          end
          crumbs << link_to(project.display_name, "/engineering_projects?q[id_eq]=#{project.id}")
        end
      end
    elsif params[:action] == 'show'
      st = EngineeringSalaryTable.where(id: params[:id]).first
      project = st.try(:project)
      if project.present?
        crumbs << link_to(project.display_name, "/engineering_projects?q[id_eq]=#{project.id}")
        crumbs << link_to('工资表', "/engineering_salary_tables?q[project_id_eq]=#{project.id}")
      end
    end

    crumbs
  end

  index has_footer: true do
    selectable_column

    sum_fields = resource_class.sum_fields
    sum = sum_fields.reduce({}) do |ha, field|
      ha[field] = collection.sum(field)
      ha
    end

    column :name, footer: '合计'
    column :type, sortable: :updated_at do |obj|
      obj.model_name.human.gsub('工资表', '')
    end
    column :start_date
    column :end_date
    column :amount, footer: sum[:amount]
    column :project, sortable: :engineering_project_id do |obj|
      project = obj.project
      link_to project.display_name, "/engineering_projects?utf8=✓&q%5Bid_equals%5D=#{project.id}&commit=过滤", target: '_blank'
    end
    column :remark
    column :created_at
    column :updated_at

    # column :audition_status, sortable: :id

    column :salary_item_detail, sortable: :updated_at do |obj|
      if obj.type == 'EngineeringBigTableSalaryTable'
      else
        parts = obj.class.name.underscore.pluralize.split('_')
        parts[-1] = parts[-1].sub('table', 'item')
        path = parts.join('_')

        project_id = obj.project.id

        ul do
          li( link_to "查看", "/#{path}?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.id}&commit=过滤", target: '_blank' )
          unless obj.project.locked
            li( link_to "导入", "/#{path}/import_new?engineering_salary_table_id=#{obj.id}", target: '_blank' )
            li( link_to "添加", "/#{path}/new?project_id=#{project_id}&salary_table_id=#{obj.id}", target: "_blank" )
          end
        end
      end
    end

    actions defaults: false do |obj|
      item "查看", engineering_salary_table_path(obj)
      unless obj.project.locked
        text_node "&nbsp;&nbsp;".html_safe
        item "编辑", edit_engineering_salary_table_path(obj)
        text_node "&nbsp;&nbsp;".html_safe
        item "删除", engineering_salary_table_path(obj), method: :delete
      end

      # text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #
      # item "发票",  "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{obj.id}&invoicable_type%5D=#{obj.class.name}&commit=过滤&order=id_desc"

      # if current_admin_user.finance_admin?
      #   if obj.audition.try(:already_audit?)
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "解除复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=init"
      #   else
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "确认复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=already_audit"
      #   end
      # elsif current_admin_user.finance_normal?
      #   if obj.audition.nil? or obj.audition.try(:init?)
      #     text_node "&nbsp;&nbsp;|&nbsp;&nbsp;".html_safe
      #     item "申请复核", "#{update_status_audition_items_path}?auditable_id=#{obj.id}&auditable_type=#{obj.class.name}&status=apply_audit"
      #   end
      # end
    end
  end

  # filter :project, as: :select, collection: ->{ EngineeringProject.as_filter }.call
  filter :name
  filter :type, as: :select, collection: ->{ EngineeringSalaryTable.types.map{|ty| [ty.model_name.human, ty.to_s]} }.call
  filter :start_date
  filter :end_date
  preserve_default_filters!
  remove_filter :audition
  remove_filter :references
  remove_filter :project
  remove_filter :activities
  remove_filter :attachment

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) \
    + [{references_attributes: [:id, :_destroy, :name, :url, :remark]}]
  }

  action_item :new, only: [:index] do
    if params['q'].present? && (pid=params['q']['project_id_eq']).present?
      link_to '新建工资表', "/engineering_salary_tables/new?project_id=#{pid}"
    else
      link_to '新建工资表', "/engineering_salary_tables/new"
    end
  end

  action_item :edit, only: [:show] do
    unless resource.project.locked
      link_to '编辑工资表', "/engineering_salary_tables/#{resource.id}/edit"
    end
  end
  action_item :destroy, only: [:show] do
    unless resource.project.locked
      link_to '删除工资表', "/engineering_salary_tables/#{resource.id}", method: :delete
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    url, query_string = request.url.split('?')
    if url.split('/')[-1] == 'new'
      pid = query_string.split('=').last rescue nil
      pr = EngineeringProject.where(id: pid).first

      f.inputs do
        f.input :name, as: :string
        # if request.url.split('/')[-1] == 'new'
        f.input :type, as: :radio, collection: ->{ EngineeringSalaryTable.new_record_types.map{|k| [k.model_name.human, k.to_s]} }.call
        if pr.present?
          f.input :project, as: :select, collection: [ [pr.display_name_with_customer, pid, {selected: true}] ]
        else
          f.input :project, collection: ->{ EngineeringProject.as_filter }.call
        end
        # end
        f.input :start_date, as: :datepicker, hint: '请确保在项目的起止日期内'
        f.input :end_date, as: :datepicker, hint: '请确保在项目的起止日期内'
        f.input :amount, as: :number
        f.input :remark, as: :text
      end
    else
      if resource.type == 'EngineeringBigTableSalaryTable'
        tabs do
          tab "基本信息" do
            f.inputs do
              f.input :name, as: :string
              f.input :start_date, as: :datepicker, hint: '请确保在项目的起止日期内'
              f.input :end_date, as: :datepicker, hint: '请确保在项目的起止日期内'
              f.input :amount, as: :number
              f.input :attachment, as: :file
              f.input :remark, as: :text
            end
          end
          tab "大表链接" do
            f.inputs do
              f.has_many :references, allow_destroy: true, new_record: true do |a|
                a.input :name, as: :string
                a.input :url, as: :string
                a.input :remark, as: :string
              end
            end
          end
        end
      else
        f.inputs do
          f.input :name, as: :string
          f.input :start_date, as: :datepicker, hint: '请确保在项目的起止日期内'
          f.input :end_date, as: :datepicker, hint: '请确保在项目的起止日期内'
          f.input :amount, as: :number
          f.input :remark, as: :text
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :project do |obj|
        link_to obj.project.name, engineering_project_path(obj.project), target: '_blank'
      end
      row :start_date
      row :end_date
      row :amount
      row :type do |obj|
        obj.model_name.human
      end
      if resource.type == 'EngineeringBigTableSalaryTable'
        row :attachment do |obj|
          link_to (obj.attachment_identifier || '无'), (obj.attachment.try(:url) || '#')
        end
      end
      row :remark
      row :created_at
      row :updated_at
    end

    if resource.type == 'EngineeringBigTableSalaryTable'
      panel "大表链接" do
        table_for resource.references do
          column :name do |obj|
            url = obj.url
            url = "http://#{url}" unless url.start_with?('http')
            link_to obj.name, url, target: '_blank'
          end
          column :remark
        end
      end
    end

    active_admin_comments
  end

  # member_action :update, method: :post do
  #   attrs = params.require(:engineering_salary_table).permit( EngineeringSalaryTable.ordered_columns )
  #
  #   begin
  #     obj = EngineeringSalaryTable.find(params[:id])
  #     obj.update! attrs
  #     redirect_to engineering_salary_table_path(obj), notice: "成功更新工资表<#{obj.name}>"
  #   rescue => e
  #     redirect_to engineering_salary_table_path(obj), alert: "更新失败，#{e.message}"
  #   end
  # end

  collection_action :import_demo do
    # Check params
    if params[:type] == 'normal'
      model = EngineeringNormalSalaryItem
    elsif params[:type] == 'tax'
    end
    columns = EngineeringNormalSalaryItem.import_columns

    filename = I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.xlsx'
    dir = Pathname("tmp/import_demo")
    dir.mkdir unless dir.exist?
    filepath = dir.join(filename)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet do |sheet|
        stat = columns.map{|col| model.human_attribute_name(col) }
        sheet.add_row stat
      end
      p.serialize(filepath.to_s)
    end

    send_file filepath
  end

  collection_action :import_new do
    render template: 'engineering_salary_tables/import_template'
  end

  collection_action :import_do, method: :post do
    project = EngineeringProject.find params[collection.name.underscore][:project_id]

    if params[collection.name.underscore][:type] == 'normal'
      model = EngineeringNormalSalaryItem
      table_model = EngineeringNormalSalaryTable
    elsif params[collection.name.underscore][:type] == 'tax'
      redirect_to :back, alert: '导入失败，暂时无法处理带个税工资表' and return
    end

    file = params[collection.name.underscore].try(:[], :file)
    redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
      if file.nil?

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless [
        "application/vnd.ms-excel",
        "application/octet-stream",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    count = xls.sheets.count
    ranges = project.split_range(count)

    columns = model.import_columns

    # Table Check
    begin
      stats = []
      xls.sheets.each_with_index do |sheet_name, sheet_id|
        sheet = xls.sheet(sheet_id).to_a

        stat = []
        sheet.each_with_index do |row, row_id|
          next if row[0].blank?

          if row[0] == '合计'
            values = stat.map(&:values).transpose.map{|ar| ar.map(&:to_f).sum}

            sum_data = row[2..-1].compact
            sum_data.each_with_index do |data, col_id|
              raise "表#{sheet_id+1} - 合计数目不等：#{sheet[0][col_id+2]}" unless \
                values[col_id+2].to_f.round(2) == data.to_f.round(2)
            end
            break
          end

          ha = {}
          row.each_with_index do |data, col_id|
            key = columns[col_id]
            ha[key] = data
          end
          stat << ha
        end

        # raise "表#{sheet_id+1} - 用工明细与工资表员工人数不等" \
        #   unless project.staffs.count == stat.count - 1

        valid_names = project.staffs.map(&:name).to_set
        stat_names  = stat[1..-1].map{|ha| ha[:name].delete(' ')}.to_set
        # raise "表#{sheet_id+1} - 用工明细与工资表员工人员不符，未找到 #{(valid_names - stat_names).join(',')}" \
        #   unless valid_names == stat_names
        raise "表#{sheet_id+1} - 未在用工明细中找到 #{(stat_names - valid_names).to_a.join(',')}" \
          if (stat_names - valid_names).to_a.present?

        stats << stat
      end

      total_amount = stats.map{|stat| stat.map{|ha| ha[:salary_in_fact].to_f}.sum}.sum.round(2)
      raise "各表合计实发金额与工程劳务费不等" \
        unless total_amount == project.project_amount.to_f.round(2)
    rescue => e
      redirect_to :back, alert: e.message and return
    end

    if ranges.count != stats.count
      redirect_to :back, alert: "项目工作量与导入工资表数目不等" and return
    end

    stats.each_with_index do |sheet_data, sheet_id|
      start_date, end_date = ranges[sheet_id]
      total_amount = sheet_data.map{|ha| ha[:salary_in_fact].to_f}.sum.round(2)
      st = table_model.create!(
        project: project,
        start_date: start_date,
        end_date: end_date,
        amount: total_amount,
        name: "#{start_date} ~ #{end_date}"
      )

      failed = false
      sheet_data.each_with_index do |data, data_id|
        next if data_id == 0
        begin
          name = data[:name].delete(' ')

          if project.staffs.where(name: name).count > 1
            identity_card = data.values.last
            if identity_card.to_s.match(/^\d{10}/)
              staff = project.staffs.where(identity_card: identity_card).first
            else
              raise "发现同名员工，请在所有员工#{name}的最后一列附上身份证号"
            end
          else
            staff = project.staffs.where(name: name).first
          end

          model.create!(data.reject{|k| k == :id or k == :name or k.blank?}.merge({
            salary_table: st,
            staff: staff
          }))
        rescue => e
          data[:error] = e.message
          failed = true
        end

        if failed
          st.reload.destroy

          filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
          filepath = Pathname("tmp/#{filename}.#{Time.stamp}.xlsx")
          Axlsx::Package.new do |p|
            p.workbook.add_worksheet do |sheet|
              sheet_data.each{|stat| sheet.add_row stat.values}
            end
            p.serialize(filepath.to_s)
          end
          send_file filepath and return
        end
      end

      st.update_column(:amount, total_amount)
    end

    redirect_to "/engineering_projects/#{project.id}/engineering_salary_tables", notice: "成功导入工资表"
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringSalaryTable.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []

    batch_action_collection.find(ids).any?{|obj| obj.project.locked}
    failed << "操作失败: 项目处于锁定状态"

    if failed.blank?
      batch_action_collection.find(ids).each do |obj|
        begin
          obj.update_attributes!(inputs)
        rescue => _
          failed << "操作失败<编号#{obj.nest_index}>: #{obj.errors.full_messages.join(', ')}"
        end
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  member_action :destroy, method: :delete do
    begin
      obj = EngineeringSalaryTable.find(params[:id])
      obj.destroy
      redirect_to "/engineering_salary_tables?q[project_id_eq]=#{obj.project.id}", notice: "成功删除工资表<#{obj.name}>"
    rescue => e
      redirect_to :back, alert: "删除失败，#{e.message}"
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:project)
    end
  end

end
