ActiveAdmin.register LaborContract do
  belongs_to :sub_company, optional: true
  belongs_to :normal_corporation, optional: true
  belongs_to :normal_staff, optional: true

  menu priority: 4

  permit_params *LaborContract.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  index do
    selectable_column

    LaborContract.ordered_columns.map(&:to_sym).map do |field|
      if field == :contract_type
        column :contract_type do |obj|
          obj.contract_type_i18n
        end
      elsif field == :normal_corporation_id
        column :normal_corporation, sortable: :normal_corporation_id
      elsif field == :normal_staff_id
        column :normal_staff, sortable: :normal_staff_id
      elsif field == :sub_company_id
        column :sub_company, sortable: :sub_company_id
      else
        column field
      end
    end

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :in_contract, as: :boolean
      f.input :contract_type, as: :radio, collection: LaborContract.contract_types_option
      f.input :contract_start_date, as: :datepicker
      f.input :contract_end_date, as: :datepicker
      f.input :arrive_current_company_at, as: :datepicker
      f.input :has_social_insurance, as: :boolean
      f.input :has_medical_insurance, as: :boolean
      f.input :current_social_insurance_start_date, as: :datepicker
      f.input :current_medical_insurance_start_date, as: :datepicker
      f.input :social_insurance_base, as: :number
      f.input :medical_insurance_base, as: :number
      f.input :house_accumulation_base, as: :number
      f.input :social_insurance_serial, as: :string
      f.input :medical_insurance_serial, as: :string
      f.input :medical_insurance_card, as: :string
      f.input :backup_date, as: :datepicker
      f.input :backup_place, as: :string
      f.input :work_place, as: :string
      f.input :work_type, as: :string
      f.input :release_date, as: :datepicker
      f.input :social_insurance_release_date, as: :datepicker
      f.input :medical_insurance_release_date, as: :datepicker
      f.input :sub_company
      f.input :normal_corporation
      f.input :normal_staff
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      boolean_columns = LaborContract.columns_of(:boolean)
      LaborContract.ordered_columns.map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          if field == :contract_type
            row :contract_type do |obj|
              obj.contract_type_i18n
            end
          elsif field == :normal_corporation_id
            row :normal_corporation
          elsif field == :normal_staff_id
            row :normal_staff
          elsif field == :sub_company_id
            row :sub_company
          else
            row field
          end
        end
      end
    end
  end
end
