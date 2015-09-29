ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [
      link_to(salary_table.corporation.name, normal_corporation_path(salary_table.corporation) ),
      link_to(salary_table.name, salary_table_path(salary_table) )
    ]
  end

  # Import
  action_item :import_new do
    link_to '导入基础工资表', import_new_salary_table_salary_items_path(salary_table)
  end

  collection_action :import_new do
    render 'import_new'
  end

  collection_action :import_do, method: :post do
    file = params[:salary_item][:file]

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    require'pry';binding.pry
    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)

    salary_table       = SalaryTable.find(params[:salary_table_id])
    normal_corporation = salary_table.normal_corporation
    valid_names        = normal_corporation.normal_staffs.map(&:name)

    stats = \
      (1..sheet.last_row).reduce({}) do |ha, i|
        name, salary = sheet.row(i)
        next if name.nil? && salary.nil?

        name.gsub!(/\s/, '')

        redirect_to :back, alert: "导入失败（重复的员工姓名：#{name}），请修改后重新上传" and return if ha[name].present?
        redirect_to :back, alert: "导入失败（未找到员工姓名：#{name}），请到右侧员工信息列表中确认" and return if !valid_names.include?(name)

        ha[name] = salary
        ha
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

    actions
  end

  # Edit
  permit_params :staff_name, :salary_deserve, :salary_table_id

  form partial: 'form'

  controller do
    def create
      st = SalaryTable.find(params[:salary_table_id])
      name = permitted_params[:salary_item][:staff_name]
      salary = permitted_params[:salary_item][:salary_deserve].to_f

      begin
        SalaryItem.create_by(salary_table: st, name: name, salary: salary)

        redirect_to salary_table_salary_items_path(st), notice: "成功创建基础工资条"
      rescue => e
        redirect_to new_salary_table_salary_item_path(st), alert: "创建失败，#{e.message}"
      end
    end
  end
end
