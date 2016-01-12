ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [
      link_to(salary_table.corporation.name, normal_corporation_path(salary_table.corporation) ),
      link_to(salary_table.name, salary_table_salary_items_path(salary_table) )
    ]
  end

  # Index
  index do
    selectable_column

    custom_sortable = {
      normal_staff: :normal_staff_id,
      staff_account: :normal_staff_id
    }

    fields = SalaryItem.columns_based_on(view: params[:view], custom: params[:custom])
    present_fields = fields.select{|key| collection.map{|obj| obj.send(key)}.any?(&:present?)}

    present_fields.each do |field|
      if custom_sortable.keys.include? field
        column field, sortable: custom_sortable[field]
      else
        column field
      end
    end

    actions
  end

  filter :id
  filter :normal_staff_account, as: :string
  filter :normal_staff_name, as: :string
  filter :salary_deserve
  filter :income_tax
  filter :total_personal
  filter :salary_in_fact
  filter :total_company
  filter :admin_amount
  filter :total_sum
  filter :total_sum_with_admin_amount
  preserve_default_filters!
  remove_filter :salary_table
  remove_filter :normal_staff
  remove_filter :role

  # Edit
  permit_params :staff_name, :salary_deserve, :salary_table_id, :staff_identity_card

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      if request.url.split('/')[-1] == 'new'
        st = SalaryTable.find(params[:salary_table_id])
        corp = st.corporation
        f.input :staff_name, as: :select, collection: ->{ corp.normal_staffs.pluck(:name, :id) }.call, hint: "合作单位<#{corp.name}>的员工列表"
        f.input :staff_identity_card, as: :string, hint: "非必须，存在同名时使用"
        f.input :salary_deserve, as: :number
      elsif request.url.split('/')[-1] == 'edit'
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
          staff = staffs.where(identity_card: identity_card).first
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

    batch_action_collection.find(ids).each do |obj|
      obj.update_by(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  batch_action :manipulate_insurance_fund, form: ->{ SalaryItem.manipulate_insurance_fund_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.manipulate_insurance_fund(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  # Collection actions
  collection_action :export_xlsx do
    st = SalaryTable.find(params[:salary_table_id])

    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = st.export_xlsx(view: params[:view], options: options)
    send_file file, filename: file.basename
  end

  # Import
  action_item :import_new, only: [:index] do
    link_to '导入普通工资表', import_new_salary_table_salary_items_path(salary_table)
  end

  collection_action :import_new do
    render 'import_new'
  end

  sidebar '参考', only: :import_new do
    para "#{normal_corporation.name} 中包含 #{normal_corporation.normal_staffs.count} 名员工，分别为"
    ul do
      normal_corporation.normal_staffs.each do |staff|
        li link_to(staff.name, normal_staff_path(staff))
      end
    end
  end

  collection_action :import_do, method: :post do
    file = params[:salary_item].try(:[], :file)
    redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
      if file.nil?

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)

    salary_table       = SalaryTable.find(params[:salary_table_id])

    if salary_table.salary_items.count == 0
      records_count = (1..sheet.last_row).count
      staffs_count = salary_table.normal_corporation.normal_staffs.count
      redirect_to :back, alert: "导入失败，上传文件中条目数（#{records_count}）少于员工数（#{staffs_count}），请修改后重新上传" and return \
        if records_count < staffs_count
    end

    stats = \
      (1..sheet.last_row).reduce([]) do |ar, i|
        name, salary, identity_card = sheet.row(i)
        next if name.nil? && salary.nil?

        name.gsub!(/\s/, '')

        identity_card = identity_card.to_i.to_s if identity_card.is_a? Numeric
        ar << { name: name, salary: salary, identity_card: identity_card }
      end

    failed = []
    stats.each do |ha|
      begin
        query = ha.merge({salary_table: salary_table})
        SalaryItem.create_by(query)
      rescue => e
        failed << (ha.values << e.message)
      end
    end

    if failed.count > 0
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

      # redirect_to import_new_salary_table_salary_items_path(salary_table), alert: "导入失败， #{failed.count} 条记录存在问题"
    else
      redirect_to salary_table_salary_items_path(salary_table), notice: "成功导入 #{stats.count} 条记录"
    end

  end

end
