ActiveAdmin.register EngineeringNormalWithTaxSalaryItem do
  include ImportSupport

  menu false

  config.per_page = 100
  config.sort_order = 'engineering_staffs.created_at_asc'

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (stid=params['q']['salary_table_id_eq']).present?
        st = EngineeringSalaryTable.where(id: stid).first
        if st.present?
          project = st.project
          if project.present?
            customer = project.customer
            if customer.present?
              crumbs << link_to(customer.display_name, "/engineering_customers?q[id_eq]=#{customer.id}")
            end
            crumbs << link_to(project.display_name, "/engineering_projects?q[id_eq]=#{project.id}")
          end
          crumbs << link_to("工资表 #{st.name}", "/engineering_salary_tables?q[id_eq]=#{st.id}")
        end
      end
    else
      []
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

    column :name, sortable: :updated_at, footer: '合计' do |obj|
      staff = obj.staff
      link_to staff.name, engineering_staff_path(staff)
    end

    if params[:q][:staff_id_eq].present?
      column :salary_table, sortable: :engineering_salary_table_id do |obj|
        st = obj.salary_table
        link_to st.start_date.to_s, "/engineering_salary_tables?q[id_eq]=#{st.id}", target: '_blank'
      end
      column :project_display, sortable: :id do |obj|
        pr = obj.salary_table.project
        link_to pr.display_name, "/engineering_projects?q[id_eq]=#{pr.id}", target: '_blank'
      end
      column :customer_display, sortable: :id do |obj|
        cu = obj.salary_table.project.customer
        link_to cu.display_name, "/engineering_customers?q[id_eq]=#{cu.id}", target: '_blank'
      end
    end

    resource_class.sum_fields.each do |field|
      column field, footer: sum[field]
    end

    column :seal_index, sortable: 'engineering_staffs.seal_index' do |obj|
      obj.staff.seal_index
    end

    actions
  end

  preserve_default_filters!
  remove_filter :salary_table
  remove_filter :staff
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      if request.url.index('/new')
        project = EngineeringProject.find(params[:project_id])
        st = EngineeringSalaryTable.find(params[:salary_table_id])
        valid_ids = project.staffs.map(&:id) - st.salary_items.map(&:engineering_staff_id)
        f.input :staff, as: :select, collection: ->{ EngineeringStaff.where(id: valid_ids) }.call, hint: '可添加的员工集合为，出现在项目的用工明细，但是还未生成工资条的员工'
        f.input :engineering_salary_table_id, as: :hidden, input_html: { value: params[:salary_table_id] }
        f.input :salary_deserve, as: :number
        f.input :social_insurance, as: :number, input_html: { value: EngineeringCompanySocialInsuranceAmount.query_amount(date: st.try(:start_date) ) }
        f.input :medical_insurance, as: :number, input_html: { value: EngineeringCompanyMedicalInsuranceAmount.query_amount(date: st.try(:start_date) ) }
      elsif request.url.index('/edit')
        f.input :salary_deserve, as: :number
        f.input :social_insurance, as: :number
        f.input :medical_insurance, as: :number
        f.input :tax, as: :number
      end
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name do |obj|
        staff = obj.staff
        link_to staff.name, engineering_staff_path(staff)
      end
      row :salary_table do |obj|
        st = obj.salary_table
        link_to st.name, engineering_salary_table_path(st)
      end
      row :project do |obj|
        pr = obj.salary_table.project
        link_to pr.name, engineering_project_path(pr)
      end
      (resource.class.ordered_columns(without_foreign_keys: true) - [:id]).each do |field|
        row field
      end
      row :seal_index do |obj|
        obj.staff.seal_index
      end
    end
    active_admin_comments
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringNormalWithTaxSalaryItem.batch_form_fields } do |ids|
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

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options[:order] = params[:order] if params[:order].present?
    options.update(params[:q])

    file = EngineeringNormalWithTaxSalaryItem.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :import_new do
    render 'import_template'
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

    columns = collection.ordered_columns(export:true)

    st_id = params[:engineering_normal_with_tax_salary_item][:engineering_salary_table_id]
    st = EngineeringSalaryTable.find(st_id)
    project = st.project

    stats = []
    data.each_with_index do |row, id|
      stat = {}
      row.each_with_index do |v, idx|
        key = columns[idx]
        value = (String === v ? v.strip : v)
        stat[key] = value
      end

      stats << stat
    end

    failed = []
    stats.each_with_index do |stat, idx|
      if idx == 0
        failed << stat.values
      else
        begin
          name = stat[:engineering_staff_id].to_s.delete(' ')
          engineering_staff_id = project.staffs.where(name: name).first.try(:id)
          raise "未找到员工，请确认员工出现在项目的用工明细中" if engineering_staff_id.blank?
          collection.create!(stat.merge({
            engineering_staff_id: engineering_staff_id,
            engineering_salary_table_id: st.id
          }))
        rescue => e
          failed << (stat.values << e.message)
        end
      end
    end

    if failed.count > 1
      # generate new xls file

      filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
      filepath = Pathname("tmp/#{filename}.#{Time.stamp}.xlsx")
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet do |sht|
          failed.each{|stat| sht.add_row stat}
        end
        p.serialize(filepath.to_s)
      end
      send_file filepath
    else
      redirect_to send("#{collection.name.underscore.pluralize}_path"), notice: "成功导入 #{stats.count-1} 条记录"
    end
  end

  collection_action :create, method: :post do
    attrs = params.require(:engineering_normal_with_tax_salary_item).permit( EngineeringNormalWithTaxSalaryItem.ordered_columns )

    begin
      obj = EngineeringNormalWithTaxSalaryItem.create! attrs
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.engineering_salary_table_id}&commit=过滤", notice: "成功创建工资条<#{obj.staff.name}>"
    rescue => e
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{attrs[:engineering_salary_table_id]}&commit=过滤", alert: "创建失败，#{e.message}"
    end
  end

  member_action :update, method: :post do
    attrs = params.require(:engineering_normal_with_tax_salary_item).permit( EngineeringNormalWithTaxSalaryItem.ordered_columns )

    begin
      obj = EngineeringNormalWithTaxSalaryItem.find(params[:id])
      obj.update! attrs
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{attrs[:engineering_salary_table_id]}&commit=过滤", notice: "成功更新工资条<#{obj.staff.name}>"
    rescue => e
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{attrs[:engineering_salary_table_id]}&commit=过滤", alert: "更新失败，#{e.message}"
    end
  end

  member_action :destroy, method: :delete do
    begin
      obj = EngineeringNormalWithTaxSalaryItem.find(params[:id])
      obj.destroy
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.engineering_salary_table_id}&commit=过滤", notice: "成功删除工资条<#{obj.staff.name}>"
    rescue => e
      redirect_to "/engineering_normal_with_tax_salary_items?utf8=✓&q%5Bsalary_table_id_eq%5D=#{obj.engineering_salary_table_id}&commit=过滤", alert: "删除失败，#{e.message}"
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:staff)
    end
  end

end
