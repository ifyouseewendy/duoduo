ActiveAdmin.register NormalStaff do

  menu \
    parent: I18n.t("activerecord.models.staff"),
    priority: 21

  permit_params NormalStaff.column_names

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :normal_corporation, as: :select
      f.input :nest_id, as: :number
      f.input :name, as: :string
      f.input :company_name, as: :string
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
      f.input :current_social_insurance_start_date, as: :datepicker
      f.input :current_medical_insurance_start_date, as: :datepicker
      f.input :social_insurance_base, as: :number
      f.input :medical_insurance_base, as: :number
      f.input :has_social_insurance, as: :boolean
      f.input :has_medical_insurance, as: :boolean
      f.input :in_service, as: :boolean
      f.input :in_release, as: :boolean
      f.input :house_accumulation_base, as: :number
      f.input :arrive_current_company_at, as: :datepicker
      f.input :contract_start_date, as: :datepicker
      f.input :contract_end_date, as: :datepicker
      f.input :social_insurance_serial, as: :string
      f.input :medical_insurance_serial, as: :string
      f.input :medical_insurance_card, as: :string
      f.input :backup_date, as: :datepicker
      f.input :backup_place, as: :string
      f.input :work_place, as: :string
      f.input :work_type, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end
end
