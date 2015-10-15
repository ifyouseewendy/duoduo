ActiveAdmin.register NormalCorporation do
  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.corporation"),
    priority: 21

  permit_params *NormalCorporation.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  scope "最近10条更新" do |record|
    record.updated_latest_10
  end

  index do
    selectable_column

    column :id
    column :name

    columns = NormalCorporation.ordered_columns(without_foreign_keys: true) - %i(id name)

    column :sub_companies_display, sortable: :id

    column :normal_staffs, sortable: :id do |obj|
      link_to "普通员工列表", normal_corporation_normal_staffs_path(obj)
    end

    column :stuff_count, sortable: ->(obj){ obj.stuff_count }
    column :stuff_has_insurance_count, sortable: ->(obj){ obj.stuff_has_insurance_count }

    column :labor_contracts, sortable: :id do |obj|
      link_to "劳务合同列表", "/labor_contracts?utf8=✓&q%5Bnormal_corporation_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end

    column :salary_tables, sortable: :id do |obj|
      link_to "普通工资表", normal_corporation_salary_tables_path(obj)
    end

    columns.map do |field|
      if field == :admin_charge_type
        # enum
        column :admin_charge_type do |obj|
          obj.admin_charge_type_i18n
        end
      else
        column field
      end
    end
    actions
  end

  preserve_default_filters!
  remove_filter :normal_staffs
  remove_filter :labor_contracts
  remove_filter :salary_tables
  remove_filter :salary_items

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :sub_companies, as: :check_boxes
      f.input :name, as: :string
      f.input :license, as: :string
      f.input :taxpayer_serial, as: :string
      f.input :organization_serial, as: :string
      f.input :corporate_name, as: :string
      f.input :address, as: :string
      f.input :account, as: :string
      f.input :account_bank, as: :string
      f.input :contact, as: :string
      f.input :telephone, as: :phone
      f.input :contract_due_time, as: :datepicker
      f.input :contract_amount, as: :number
      f.input :admin_charge_type, as: :radio, collection: NormalCorporation.admin_charge_types_option
      f.input :admin_charge_amount, as: :number
      f.input :expense_date, as: :datepicker
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      NormalCorporation.ordered_columns(without_foreign_keys: true).map do|field|
        if field == :admin_charge_type
          row :admin_charge_type do |obj|
            obj.admin_charge_type_i18n
          end
        else
          row field
        end
      end
      row :sub_companies do |corp|
        corp.sub_company_names.join(', ')
      end
    end

    panel "业务代理合同" do
      tabs do
        resource.sub_companies.each do |comp|
          tab comp.name do
            render partial: "shared/contract", locals: {sub_company: comp, corporation: resource}
          end
        end
      end
    end

    active_admin_comments
  end

  sidebar '链接', only: [:show] do
    ul do
      li link_to NormalStaff.model_name.human, normal_corporation_normal_staffs_path(normal_corporation)
      li link_to SalaryTable.model_name.human, normal_corporation_salary_tables_path(normal_corporation)
    end
  end

  # Batch actions
  batch_action :batch_edit, form: NormalCorporation.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

    file = NormalCorporation.export_xlsx(options: options)
    send_file file, filename: file.basename
  end
end
