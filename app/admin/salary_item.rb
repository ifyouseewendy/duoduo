ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [salary_table.corporation.name, salary_table.name]
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
