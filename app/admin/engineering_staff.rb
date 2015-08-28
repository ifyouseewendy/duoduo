ActiveAdmin.register EngineeringStaff do
  include ImportDemo

  active_admin_import \
    validate: true,
    template: 'import' ,
    batch_transaction: true,
    template_object: ActiveAdminImport::Model.new(
      csv_options: {col_sep: ",", row_sep: nil, quote_char: nil},
      csv_headers: @resource.ordered_columns(without_base_keys: true, without_foreign_keys: true),
      force_encoding: :auto,
      allow_archive: false,
  )

  menu \
    parent: I18n.t("activerecord.models.staff"),
    priority: 22

  permit_params *EngineeringStaff.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  index do
    selectable_column
    EngineeringStaff.ordered_columns.map(&:to_sym).map do |field|
      if field == :gender
        # enum
        column :gender do |obj|
          obj.gender_i18n
        end
      elsif field == :engineering_corporation_id
        column :engineering_corporation, sortable: :engineering_corporation_id
      else
        column field
      end
    end
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :engineering_staffs_corporation, as: :select
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :company_name, as: :string
      f.input :identity_card, as: :string
      f.input :birth, as: :datepicker
      f.input :age, as: :number
      f.input :gender, as: :radio, collection: EngineeringStaff.genders_option
      f.input :nation, as: :string
      f.input :address, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      boolean_columns = EngineeringStaff.columns_of(:boolean)
      EngineeringStaff.ordered_columns.map(&:to_sym).map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          if field == :gender
            row :gender do |obj|
              obj.gender_i18n
            end
          elsif field == :engineering_corporation_id
            row :engineering_corporation
          else
            row field
          end
        end
      end
    end
  end
end
