ActiveAdmin.register EngineeringStaff do
  include ImportSupport

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
          else
            row field
          end
        end
      end
    end
  end

  # Batch actions
  batch_action :batch_edit, form: EngineeringStaff.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end
end
