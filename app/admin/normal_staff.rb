ActiveAdmin.register NormalStaff do
  belongs_to :normal_corporation, optional: true

  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.staff"),
    priority: 21

  permit_params *NormalStaff.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  index do
    selectable_column
    NormalStaff.ordered_columns.map(&:to_sym).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      elsif field == :normal_corporation_id
        column :normal_corporation, sortable: :normal_corporation_id
      elsif field == :sub_company_id
        column :sub_company, sortable: :sub_company_id
      else
        column field
      end
    end
    actions do |obj|
      a link_to "查看劳务合同", normal_staff_labor_contracts_path(obj)
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :account, as: :string
      f.input :account_bank, as: :string
      f.input :identity_card, as: :string
      f.input :birth, as: :datepicker
      f.input :age, as: :number
      f.input :gender, as: :radio, collection: NormalStaff.genders_option
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
      boolean_columns = NormalStaff.columns_of(:boolean)
      NormalStaff.ordered_columns.map(&:to_sym).map do |field|
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
      li link_to lc.name, normal_staff_labor_contract_path(normal_staff, lc), class: 'current_contract'

      li link_to "全部合同", normal_staff_labor_contracts_path(normal_staff)
    end
  end

  # Batch actions
  batch_action :batch_edit, form: NormalStaff.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end
end
