ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [
      link_to(salary_table.corporation.name, normal_corporation_path(salary_table.corporation) ),
      link_to(salary_table.name, salary_table_salary_items_path(salary_table) )
    ]
  end

  # Import
  action_item :import_new do
    link_to '导入原始工资表', import_new_salary_table_salary_items_path(salary_table)
  end

  collection_action :import_new do
    render 'import_new'
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

  sidebar '参考', only: :import_new do
    para "#{normal_corporation.name} 中包含 #{normal_corporation.normal_staffs.count} 名员工，分别为"
    ul do
      normal_corporation.normal_staffs.each do |staff|
        li link_to(staff.name, normal_staff_path(staff))
      end
    end
  end

  # Index
  index do
    selectable_column

    if params[:view] == 'proof'
      column :id
      column :staff_identity_card, sortable: ->(obj){ obj.staff_identity_card }
      column :staff_account, sortable: ->(obj){ obj.staff_account }
      column :staff_category, sortable: ->(obj){ obj.staff_category }
      column :staff_company, sortable: -> (obj){ obj.staff_company.id }
      column :normal_staff, sortable: :normal_staff_id
      column :salary_table, sortable: :salary_table_id
      column :salary_deserve
      column :annual_reward
      column :pension_personal
      column :pension_margin_personal
      column :unemployment_personal
      column :unemployment_margin_personal
      column :medical_personal
      column :medical_margin_personal
      column :house_accumulation_personal
      column :big_amount_personal
      column :income_tax
      column :salary_card_addition
      column :medical_scan_addition
      column :salary_pre_deduct_addition
      column :insurance_pre_deduct_addition
      column :physical_exam_addition
      column :total_personal
      column :salary_in_fact
      column :pension_company
      column :pension_margin_company
      column :unemployment_company
      column :unemployment_margin_company
      column :medical_company
      column :medical_margin_company
      column :injury_company
      column :injury_margin_company
      column :birth_company
      column :birth_margin_company
      column :accident_company
      column :house_accumulation_company
      column :total_company
      column :total_sum
    elsif params[:view] == 'card'
      column :staff_account, sortable: ->(obj){ obj.staff_account }
      column :normal_staff, sortable: :normal_staff_id
      column :salary_in_fact
    elsif params[:view] == 'custom'
      columns = params[:columns].split('-')

      column :id if columns.include? 'id'
      column :staff_identity_card, sortable: ->(obj){ obj.staff_identity_card } if columns.include? 'staff_identity_card'
      column :staff_account, sortable: ->(obj){ obj.staff_account } if columns.include? 'staff_account'
      column :staff_category, sortable: ->(obj){ obj.staff_category } if columns.include? 'staff_category'
      column :staff_company, sortable: -> (obj){ obj.staff_company.id } if columns.include? 'staff_company'
      column :normal_staff, sortable: :normal_staff_id if columns.include? 'normal_staff'
      column :salary_table, sortable: :salary_table_id if columns.include? 'salary_table'

      sortable_columns = %w(id staff_identity_card staff_account staff_category staff_company normal_staff salary_table)
      (columns - sortable_columns).each{|col| column col.to_sym}
    else
      column :id
      column :staff_identity_card, sortable: ->(obj){ obj.staff_identity_card }
      column :staff_account, sortable: ->(obj){ obj.staff_account }
      column :staff_category, sortable: ->(obj){ obj.staff_category }
      column :staff_company, sortable: -> (obj){ obj.staff_company.id }
      column :normal_staff, sortable: :normal_staff_id
      column :salary_table, sortable: :salary_table_id
      column :salary_deserve
      column :annual_reward
      column :pension_personal
      column :pension_margin_personal
      column :unemployment_personal
      column :unemployment_margin_personal
      column :medical_personal
      column :medical_margin_personal
      column :house_accumulation_personal
      column :big_amount_personal
      column :income_tax
      column :salary_card_addition
      column :medical_scan_addition
      column :salary_pre_deduct_addition
      column :insurance_pre_deduct_addition
      column :physical_exam_addition
      column :total_personal
      column :salary_in_fact
      column :pension_company
      column :pension_margin_company
      column :unemployment_company
      column :unemployment_margin_company
      column :medical_company
      column :medical_margin_company
      column :injury_company
      column :injury_margin_company
      column :birth_company
      column :birth_margin_company
      column :accident_company
      column :house_accumulation_company
      column :total_company
      column :social_insurance_to_salary_deserve
      column :social_insurance_to_pre_deduct
      column :medical_insurance_to_salary_deserve
      column :medical_insurance_to_pre_deduct
      column :house_accumulation_to_salary_deserve
      column :house_accumulation_to_pre_deduct
      column :admin_amount
      column :total_sum
      column :total_sum_with_admin_amount
      column :created_at
      column :updated_at
      column :remark
    end

    actions
  end

  # Edit
  permit_params :staff_name, :salary_deserve, :salary_table_id, :staff_identity_card

  form partial: 'form'

  controller do
    def create
      st = SalaryTable.find(params[:salary_table_id])
      name = permitted_params[:salary_item][:staff_name]
      salary = permitted_params[:salary_item][:salary_deserve].to_f
      identity_card = permitted_params[:salary_item][:staff_identity_card]

      begin
        SalaryItem.create_by(
          salary_table: st,
          salary: salary,
          name: name,
          identity_card: identity_card
        )

        redirect_to salary_table_salary_items_path(st), notice: "成功创建基础工资条"
      rescue => e
        redirect_to new_salary_table_salary_item_path(st), alert: "创建失败，#{e.message}"
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: SalaryItem.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update_by(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  batch_action :manipulate_insurance_fund, form: SalaryItem.manipulate_insurance_fund_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.manipulate_insurance_fund(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  # controller do
  collection_action :export_xlsx do
    st = SalaryTable.find(params[:salary_table_id])

    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = st.export_xlsx(view: params[:view], options: options)
    send_file file, filename: file.basename
  end
end
