ActiveAdmin.register NormalStaff do
  belongs_to :normal_corporation, optional: true

  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 3

  permit_params ->{ @resource.ordered_columns(without_base_keys: true, without_foreign_keys: true) }

  index do
    selectable_column

    column :id
    column :name
    column :sub_company, sortable: :sub_company_id
    column :normal_corporation, sortable: :normal_corporation_id

    (resource_class.ordered_columns.map(&:to_sym) - [:id, :name, :sub_company, :normal_corporation]).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      else
        column field
      end
    end
    actions do |obj|
      a link_to "查看劳务合同", normal_staff_labor_contracts_path(obj), class: "expand_table_action_width"
    end
  end

  preserve_default_filters!
  remove_filter :salary_items
  remove_filter :guard_salary_items
  remove_filter :non_full_day_salary_items
  remove_filter :labor_contracts

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :account, as: :string
      f.input :account_bank, as: :string
      f.input :identity_card, as: :string
      f.input :birth, as: :datepicker
      f.input :age, as: :number
      f.input :gender, as: :radio, collection: ->{ NormalStaff.genders_option }
      f.input :nation, as: :string
      f.input :grade, as: :string
      f.input :address, as: :string
      f.input :telephone, as: :string
      f.input :social_insurance_start_date, as: :datepicker
      f.input :in_service, as: :boolean
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      boolean_columns = resource.class.columns_of(:boolean)
      resource.class.ordered_columns.map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          if field == :gender
            row :gender do |obj|
              obj.gender_i18n
            end
          elsif field == :normal_corporation_id
            row :normal_corporation
          elsif field == :sub_company_id
            row :sub_company
          else
            row field
          end
        end
      end
    end
  end

  sidebar '劳务合同', only: [:show] do
    ul do
      lc = normal_staff.labor_contracts.active.first
      if lc.present?
        li link_to lc.name, normal_staff_labor_contract_path(normal_staff, lc), class: 'current_contract'
      end

      li link_to "全部合同", normal_staff_labor_contracts_path(normal_staff)
    end
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ NormalStaff.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end
end
