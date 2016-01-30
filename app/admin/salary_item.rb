ActiveAdmin.register SalaryItem do
  belongs_to :salary_table, optional: true

  menu false

  breadcrumb do
    crumbs = []

    if (stid=params['salary_table_id']).present?
      st = SalaryTable.where(id: stid).first
      if st.present?
        crumbs << link_to('工资表', "/salary_tables")
        crumbs << link_to(st.name, "/salary_tables?q[id_eq]=#{st.id}")
      end
    elsif params['q'].present?
      if (nsid=params['q']['normal_staff_id_eq']).present?
        ns = NormalStaff.where(id: nsid).first
        if ns.present?
          crumbs << link_to('员工信息', "/normal_staffs")
          crumbs << link_to(ns.name, "/normal_staffs?q[id_eq]=#{ns.id}")
        end
      end
    end

    crumbs
  end

  config.per_page = 100
  config.sort_order = 'nest_index_asc,role_asc'

  scope "全部" do |record|
    record.all
  end

  # Index
  index row_class: ->(ele){ 'transfer' if ele.transfer? }, has_footer: true  do
    selectable_column

    staff_view = params[:q][:normal_staff_id_eq].present? rescue nil
    if staff_view
      column :corporation_display, sortable: :salary_table_id do |obj|
        corp = obj.salary_table.normal_corporation
        link_to corp.name, "/normal_corporations?q[id_eq]=#{corp.id}", target: '_blank'
      end
      column :salary_table_display, sortable: :salary_table_id do |obj|
        st = obj.salary_table
        link_to st.name, "/salary_tables?q[id_eq]=#{st.id}", target: '_blank'
      end
    end

    custom_sortable = {
      staff_name: :staff_name,
      staff_account: :normal_staff_id
    }

    # present_fields defined in helper
    fields = present_fields(collection, params)
    sum_fields = fields & resource_class.sum_fields

    sum = sum_fields.reduce({}) do |ha, field|
      ha[field] = collection.sum(field)
      ha
    end

    fields.each_with_index do |field, idx|
      if idx == 0
        column :nest_index, footer: '合计'
        next
      end

      if custom_sortable.keys.include? field
        if field == :staff_name
          column field, sortable: custom_sortable[field] do |obj|
            link_to obj.staff_name, normal_staff_path(obj.normal_staff)
          end
        else
          column field, sortable: custom_sortable[field]
        end
      else
        opt = {}
        opt = {footer: sum[field]} if sum_fields.include?(field)
        column field, opt
      end
    end

    actions defaults: false do |obj|
      item "编辑", "/salary_items/#{obj.id}/edit"
      text_node "&nbsp;".html_safe
      item "删除", "/salary_items/#{obj.id}", method: :delete
    end
  end

  filter :nest_index
  filter :staff_account
  filter :staff_name
  filter :salary_deserve
  filter :income_tax
  filter :total_personal
  filter :salary_in_fact
  filter :total_company
  filter :admin_amount
  filter :other_amount
  filter :total_sum
  filter :total_sum_with_admin_amount
  preserve_default_filters!
  remove_filter :salary_table
  remove_filter :normal_staff
  remove_filter :role
  remove_filter :activities

  # Edit
  permit_params { resource_class.whole_columns + [:staff_identity_card] }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      if request.url.split('/')[-1] == 'new'
        st = SalaryTable.find(params[:salary_table_id])
        corp = st.corporation
        f.input :staff_name, as: :select, collection: ->{ corp.normal_staffs.pluck(:name, :id) }.call, hint: "合作单位<#{corp.name}>的员工列表"
        f.input :staff_identity_card, as: :string, hint: "非必须，存在同名或者添加非当前合作单位员工时使用"
        f.input :salary_deserve, as: :number
      elsif request.url.split('/')[-1] == 'edit'
        text_fields = SalaryItem.columns_of(:text)
        (SalaryItem.whole_columns - [:id, :nest_index]).reject{|field| field.to_s.start_with?('total')}.each do |field|
          if text_fields.include? field
            f.input field, as: :string
          else
            f.input field
          end
        end
      end
   end
    f.actions
  end

  controller do
    def create
      st = SalaryTable.find(params[:salary_table_id])
      staffs = st.corporation.normal_staffs

      staff_id = permitted_params[:salary_item][:staff_name]
      identity_card = permitted_params[:salary_item][:staff_identity_card]

      salary_deserve = permitted_params[:salary_item][:salary_deserve].to_f

      begin
        if identity_card.present?
          staff = NormalStaff.where(identity_card: identity_card).first
          raise "未找到员工，身份证号：#{identity_card}" if staff.nil?
        else
          staff = staffs.where(id: staff_id).first
          raise "未找到员工，员工编号：#{staff_id}" if staff.nil?
        end

        st.salary_items.create!(
          normal_staff: staff,
          salary_deserve: salary_deserve,
        )
        redirect_to salary_table_salary_items_path(st), notice: "成功创建基础工资条"
      rescue => e
        redirect_to new_salary_table_salary_item_path(st), alert: "创建失败，#{e.message}"
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ SalaryItem.batch_form_fields } do |ids|
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

  batch_action :manipulate_insurance_fund, form: ->{ SalaryItem.manipulate_insurance_fund_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.manipulate_insurance_fund(inputs)
      rescue => e
        failed << "操作失败<#{obj.staff_name}>：#{e.message}"
      end
    end

    if failed.blank?
      redirect_to :back, notice: "成功转移 #{ids.count} 条记录"
    else
      redirect_to :back, alert: failed.join('；')
    end

  end

  batch_action :manipulate_personal_fund, form: ->{} do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.manipulate_personal_fund(inputs)
      rescue => e
        failed << "操作失败<#{obj.staff_name}>：#{e.message}"
      end
    end

    if failed.blank?
      redirect_to :back, notice: "成功转移 #{ids.count} 条记录"
    else
      redirect_to :back, alert: failed.join('；')
    end

  end

  # Collection actions
  collection_action :export_xlsx do
    st = SalaryTable.where(id: params[:salary_table_id]).first
    staff_view = params[:q][:normal_staff_id_eq].present? rescue nil
    if st.nil? && staff_view
      st = SalaryTable.first
    end

    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options.update(params[:q]) if params[:q].present?

    file = st.export_xlsx(view: params[:view], options: options)
    send_file file, filename: file.basename
  end

  # Import
  # action_item :import_new, only: [:index] do
  #   link_to '导入基础工资表', import_new_salary_table_salary_items_path(salary_table)
  # end

  collection_action :import_new do
    render 'import_template'
  end

  sidebar "参考", only: :import_new do
    para "#{normal_corporation.name}员工列表（ 共#{normal_corporation.normal_staffs.count}人）"
    table_for normal_corporation.normal_staffs.order(name: :asc) do
      column :name do |obj|
        link_to obj.name, normal_staff_path(obj), target: '_blank'
      end
      column :identity_card
    end
  end

  collection_action :import_demo do
    model = controller_name.classify.constantize

    filename = I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.xlsx'
    dir = Pathname("tmp/import_demo")
    dir.mkdir unless dir.exist?
    filepath = dir.join(filename)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet do |sheet|
        stat = model.ordered_columns(export: true).map{|col| model.human_attribute_name(col) }
        sheet.add_row stat
      end
      p.serialize(filepath.to_s)
    end

    send_file filepath
  end

  collection_action :import_do, method: :post do
    file = params[:salary_item].try(:[], :file)
    redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
      if file.nil?

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)

    stid = params[:salary_item][:salary_table_id] rescue nil
    salary_table = SalaryTable.where(id: stid).first
    raise "未找到工资表：#{params[:salary_table_id]}，请确保导入页面是从工资表列表页的工资条导入跳转而来" if salary_table.nil?
    corporation = salary_table.normal_corporation

    # if salary_table.salary_items.count == 0
    #   records_count = (1..sheet.last_row).count
    #   staffs_count = salary_table.normal_corporation.normal_staffs.count
    #   redirect_to :back, alert: "导入失败，上传文件中条目数（#{records_count}）少于员工数（#{staffs_count}），请修改后重新上传" and return \
    #     if records_count < staffs_count
    # end

    stats = \
      (1..sheet.last_row).reduce([]) do |ar, i|
        name, salary, identity_card = sheet.row(i)
        next if name.nil? && salary.nil?

        name.gsub!(/\s/, '')

        identity_card = identity_card.to_i.to_s if identity_card.is_a? Numeric
        ar << { name: name, salary: salary, identity_card: "'#{identity_card}" }
      end

    failed = []
    stats.each_with_index do |ha, i|
      if i == 0
        failed << ha.values
        next
      end

      begin
        if ha[:identity_card].present?
          id_card = ha[:identity_card].delete("'")
          staff = NormalStaff.where(identity_card: id_card).first

          raise "未找到员工，身份证号#{id_card}" \
            unless staff.present?
          raise "通过身份证号找到员工姓名为#{staff.name}，而上传文件中为#{ha[:name]}" \
            unless staff.name == ha[:name]
        else
          staff = corporation.find_staff(name: ha[:name])
        end

        salary_table.salary_items.create!(
          normal_staff: staff,
          salary_deserve: ha[:salary]
        )
      rescue => e
        failed << (ha.values << e.message)
      end
    end

    if failed.count > 1
      # generate new xls file

      filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
      filepath = Pathname("tmp/#{filename}_#{Time.stamp}.xlsx")
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet do |sheet|
          failed.each{|stat| sheet.add_row stat}
        end
        p.serialize(filepath.to_s)
      end
      send_file filepath
    else
      redirect_to salary_table_salary_items_path(salary_table), notice: "成功导入 #{stats.count} 条记录"
    end

  end

  controller do
    # def scoped_collection
    #   end_of_association_chain.includes(:normal_staff)
    # end
  end

end
