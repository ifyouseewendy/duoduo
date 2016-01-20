ActiveAdmin.register EngineeringStaff do
  belongs_to :engineering_customer, optional: true
  include ImportSupport

  # Config
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 4

  config.per_page = 50

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (pid=params['q']['projects_id_eq']).present?
        project = EngineeringProject.where(id: pid).first
        if project.present?
          customer = project.customer
          if customer.present?
            crumbs << link_to('客户', '/engineering_customers')
            crumbs << link_to(customer.display_name, "/engineering_customers?q[id_eq]=#{customer.id}")
          end

          crumbs << link_to('项目汇总', "/engineering_projects?q[customer_id_eq]=#{customer.try(:id)}")
          crumbs << link_to(project.display_name, "/engineering_projects?q[id_eq]=#{project.id}")
        end
      elsif (cid=params['q']['customer_id_eq']).present?
        customer = EngineeringCustomer.where(id: cid).first
        if customer.present?
          crumbs << link_to('客户', '/engineering_customers')
          crumbs << link_to(customer.display_name, "/engineering_customers?q[id_eq]=#{customer.id}")
        end
      end
    end

    crumbs
  end

  # Index
  scope "全部" do |record|
    record.all
  end
  scope "不可用" do |record|
    record.disabled
  end
  scope "可用" do |record|
    record.enabled
  end

  config.sort_order = 'created_at_asc'

  index do
    selectable_column

    column :identity_card
    column :name
    column :enable, sortable: :enable do |obj|
      if obj.enable
        status_tag '可用', :yes
      else
        status_tag '不可用', :no
      end
    end
    column :customer, sortable: :id do |obj|
      link_to obj.customer.display_name, engineering_customer_path(obj.customer), target: '_blank'
    end
    column :projects, sortable: :id do |obj|
      link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bstaffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc", target: '_blank'
    end
    column :salary_item_detail, sortable: :updated_at do |obj|
      stats = []
      if obj.engineering_normal_salary_items.count > 0
        stats << ["基础", "/engineering_normal_salary_items?utf8=✓&q%5Bstaff_id_eq%5D=#{obj.id}&commit=过滤"]
      end
      if obj.engineering_normal_with_tax_salary_items.count > 0
        stats << ["基础（带个税）", "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bstaff_id_eq%5D=#{obj.id}&commit=过滤"]
      end
      ul do
        stats.each do |ar|
          li( link_to ar[0], ar[1], target: '_blank' )
        end
      end
    end

    (resource_class.ordered_columns(without_foreign_keys: true) - [:identity_card, :name, :id, :enable, :alias_name]).map(&:to_sym).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      else
        column field
      end
    end

    actions defaults: false do |obj|
      text_node "&nbsp".html_safe
      item "查看", "/engineering_staffs/#{obj.id}"
      text_node "&nbsp".html_safe
      item "编辑", "/engineering_staffs/#{obj.id}/edit"
      project_view = params['q']['projects_id_eq'] rescue nil
      unless project_view
        text_node "&nbsp".html_safe
        item "删除", "/engineering_staffs/#{obj.id}", method: :delete
      end
    end
  end

  filter :identity_card
  filter :name
  filter :enable
  preserve_default_filters!
  remove_filter :salary_items
  remove_filter :engineering_normal_salary_items
  remove_filter :engineering_normal_with_tax_salary_items
  remove_filter :engineering_big_table_salary_items
  remove_filter :engineering_dong_fang_salary_items
  remove_filter :alias_name
  remove_filter :customer
  # remove_filter :projects
  remove_filter :activities
  # filter :customer
  filter :projects, as: :select, collection: ->{ EngineeringProject.as_filter }

  permit_params {
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) + [engineering_project_ids: []]
  }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :identity_card, as: :string
      f.input :name, as: :string
      f.input :enable
      f.input :customer
      # f.input :projects, as: :select, collection: ->{ EngineeringProject.includes(:customer).map{|ep| ["#{ep.customer.display_name} - #{ep.display_name}", ep.id] } }.call
      f.input :gender, as: :radio, collection: ->{ EngineeringStaff.genders_option }.call
      f.input :remark, as: :text
    end

    f.actions
  end

  # member_action :update, method: :post do
  #   attrs = params.require(:engineering_staff).permit( EngineeringStaff.ordered_columns + [engineering_project_ids: []] )
  #
  #   begin
  #     obj = EngineeringStaff.find(params[:id])
  #     obj.update! attrs
  #
  #     redirect_to engineering_staff_path(obj), notice: "成功更新工程员工信息"
  #   rescue => e
  #     if e.message == "Staff refuse the project schedule"
  #       alert = "更新失败，多个工程项目的起止日期有重叠。"
  #       projects = params[:engineering_staff][:engineering_project_ids].map{|id| EngineeringProject.where(id: id).first }.reject(&:blank?)
  #       alert += projects.map{|pr| pr.range_output}.join('；')
  #     else
  #       alert = e.message
  #     end
  #     redirect_to engineering_staff_path(obj), alert: alert
  #   end
  # end

  show do
    attributes_table do
      row :identity_card
      row :name
      row :enable, sortable: :enable do |obj|
        if obj.enable
          status_tag '可用', :yes
        else
          status_tag '不可用', :no
        end
      end
      row :customer do |obj|
        link_to obj.customer.display_name, engineering_customer_path(obj.customer), target: '_blank'
      end
      row :projects do |obj|
        link_to "所属项目", "/engineering_projects?utf8=✓&q%5Bengineering_staffs_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc", target: '_blank'
      end

      boolean_columns = resource.class.columns_of(:boolean)
      (resource.class.ordered_columns(without_foreign_keys: true) - [:id, :identity_card, :name, :enable, :alias_name]).map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          if field == :gender
            row :gender do |obj|
              obj.gender_i18n
            end
          else
            row field
          end
        end
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringStaff.batch_form_fields } do |ids|
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

  # batch_action :assign_project, form: ->{
  #     {'engineering_project_id_工程项目' => EngineeringProject.id_name_option}
  #   } do |ids|
  #   inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access
  #   project = EngineeringProject.find(inputs[:engineering_project_id])
  #
  #   messages = []
  #   failed = false
  #   batch_action_collection.find(ids).each do |obj|
  #     begin
  #       obj.projects << project
  #       messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
  #     rescue => e
  #       failed = true
  #       messages << "操作失败，#{e.message}"
  #     end
  #   end
  #
  #   if failed
  #     redirect_to :back, alert: messages.join('；')
  #   else
  #     redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  #   end
  # end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options.update(params[:q])

    file = EngineeringStaff.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :query_free do
    project = EngineeringProject.find( params[:project_id] )

    customer = project.customer
    start_date, end_date = project.range
    own_staffs = customer.free_staffs(start_date, end_date, exclude_project_id: project.id).sort_by{|fs| [fs.remark.to_s, fs.created_at]}

    stats = {
      count: own_staffs.count,
      customer: customer.display_name,
      range_output: project.range_output,
      display_name: project.display_name
    }
    stats[:stat] = own_staffs.reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: "#{ele.name} - #{ele.remark}"
      }
    end
    render json: stats
  end

  collection_action :query_project do
    project = EngineeringProject.find( params[:project_id] )

    stats = project.staffs.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end

  # Member actions
  member_action :add_projects, method: :post do
    staff = EngineeringStaff.find(params[:id])
    projects = params[:engineering_project_ids].map{|id| EngineeringProject.where(id: id).first}.compact

    messages = []
    projects.each do |project|
      begin
        staff.projects << project
        messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  member_action :remove_projects, method: :post do
    staff = EngineeringStaff.find(params[:id])
    project_ids = staff.projects.select(:id).map(&:id) - (params[:engineering_project_ids].reject(&:blank?).map(&:to_i) rescue [])
    projects =  project_ids.map{|id| EngineeringProject.where(id: id).first}.compact

    messages = []
    projects.each do |project|
      begin
        staff.projects.delete project
        messages << "操作成功，员工<#{staff.name}>已离开项目<#{project.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  collection_action :import_demo do
    model = controller_name.classify.constantize

    filename = I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.xlsx'
    dir = Pathname("tmp/import_demo")
    dir.mkdir unless dir.exist?
    filepath = dir.join(filename)

    if params[:project_id].present?
      columns = [:id, :name, :gender, :identity_card]

      package = Axlsx::Package.new
      package.workbook do |workbook|
        workbook.add_worksheet do |sheet|
          sheet.add_row ["用工明细表"]
          stat = columns.map{|col| model.human_attribute_name(col) }
          sheet.add_row stat

          sheet.merge_cells "A1:D1"
        end
      end
      package.serialize(filepath.to_s)
    else
      columns = model.ordered_columns(export: true)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet do |sheet|
          sheet.add_row ["提供人员表"]
          stat = columns.map{|col| model.human_attribute_name(col) }
          sheet.add_row stat

          end_chr =  ('A'.ord + columns.count).chr
          sheet.merge_cells "A1:#{end_chr}1"
        end
        p.serialize(filepath.to_s)
      end
    end

    send_file filepath
  end

  collection_action :import_do, method: :post do
    file = params[collection.name.underscore].try(:[], :file)
    redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
      if file.nil?

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)
    data = sheet.to_a

    project_id = params[:engineering_staff][:project_id] rescue nil
    project = EngineeringProject.where(id: project_id).first

    if project.present?
      customer = project.customer
    else
      customer_id = params[:engineering_staff][:customer_id] rescue nil
      customer = EngineeringCustomer.where(id: customer_id).first
    end

    if project_id.present?
      columns = [:id, :name, :gender, :identity_card]
    else
      columns = collection.ordered_columns(export:true)
    end

    gender_map = {'男' => 'male', '女' => 'female'}
    gender_reverse_map = {'male' => '男', 'female' => '女'}
    stats = []
    failed = []

    data.each_with_index do |row, id|
      if id < 2
        failed << row
      else
        stat = {}
        row.each_with_index do |v, idx|
          key = columns[idx]
          next if key.blank?

          value = (String === v ? v.strip : v)
          value = gender_map[value] if gender_map.keys.include? value
          stat[key] = value
        end

        stats << stat
      end
    end

    stats.each_with_index do |stat, idx|
      begin
        identity_card = stat[:identity_card].delete("'")

        if project.present?
          staff = customer.staffs.where(identity_card: identity_card).first
          raise "无法在客户提供人员找到该身份证号" if staff.nil?
          staff.projects << project
        else
          if identity_card.end_with?('!') or identity_card.end_with?('！')
            name_check = false
            identity_card = identity_card.delete('!').delete('！')
          else
            name_check = true
          end

          if (es=EngineeringStaff.where(identity_card: identity_card).first).present?
            raise "身份证号已被使用，出现在客户 #{es.customer.display_name} 中，姓名 #{es.name}"
          end

          if name_check
            alike_staffs = customer.staffs.where(name: stat[:name]).where.not(identity_card: identity_card)
            if alike_staffs.count > 0
              display_staffs = alike_staffs.map{|st| "#{st.name} - #{st.identity_card}"}.join(', ')
              raise "在当前客户下找到同名员工，请检查：#{display_staffs}。如果确定为两名不同员工，请在身份证号后面附加！以强制导入"
            end
          end

          stat[:identity_card] = identity_card

          staff = collection.new(stat.merge(
            { engineering_customer_id: customer.id}
          ))
          staff.save

          if staff.errors.present?
            raise staff.errors.full_messages.join(', ')
          end
        end

      rescue => e
        failed << (stat.values << e.message << e.backtrace[0])
      end
    end

    if failed.count > 2
      # generate new xls file

      filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
      filepath = Pathname("tmp/#{filename}.#{Time.stamp}.xlsx")
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet do |sht|
          failed.each_with_index do |stat, fid|
            if fid >= 2
              id_card_idx = columns.index(:identity_card)
              stat[id_card_idx] = "'#{stat[id_card_idx]}" unless stat[id_card_idx].start_with?("'")

              gender_idx = columns.index(:gender)
              stat[gender_idx] = gender_reverse_map[ stat[gender_idx] ]
            end

            sht.add_row stat
          end

          end_chr =  ('A'.ord + failed[1].count).chr
          sht.merge_cells "A1:#{end_chr}1"
        end
        p.serialize(filepath.to_s)
      end
      send_file filepath
    else
      if project.present?
        redirect_to "/engineering_staffs?q[projects_id_eq]=#{project.id}", notice: "成功导入 #{stats.count} 条记录"
      else
        redirect_to "/engineering_staffs?q[customer_id_eq]=#{customer.id}", notice: "成功导入 #{stats.count} 条记录"
      end
    end

  end

  controller do
    before_filter :set_page_title, only: [:index]

    def set_page_title
      if params['q'].present?
        if params['q']['projects_id_eq'].present?
          @page_title = '用工明细'
        elsif params['q']['customer_id_eq'].present?
          @page_title = '提供人员'
        end
      end
    end

    def scoped_collection
      end_of_association_chain.includes(:customer)
    end
  end
end
