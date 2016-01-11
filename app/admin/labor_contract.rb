ActiveAdmin.register LaborContract do
  belongs_to :sub_company, optional: true
  belongs_to :normal_corporation, optional: true
  belongs_to :normal_staff, optional: true

  include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 2

  scope "全部" do |record|
    record.all
  end
  scope "活动" do |record|
    record.active
  end
  scope "存档" do |record|
    record.archive
  end

  index do
    selectable_column

    column :id
    column :normal_staff, sortable: :normal_staff_id
    column :sub_company, sortable: :normal_corporation_id do |obj|
      sc = obj.normal_corporation.sub_company
      link_to sc.name, sub_company_path(sc)
    end
    column :normal_corporation, sortable: :normal_corporation_id do |obj|
      corp = obj.normal_corporation
      link_to corp.name, normal_corporation_path(corp)
    end
    column :in_contract, sortable: :in_contract do |obj|
      if obj.in_contract
        status_tag '活动', 'yes'
      else
        status_tag '存档', 'no'
      end
    end
    column :contract_type do |obj|
      obj.contract_type_i18n
    end

    displayed_columns = %i(id normal_staff_id normal_corporation_id in_contract contract_type)

    (resource_class.ordered_columns.map(&:to_sym) - displayed_columns).map do |field|
      column field
    end

    actions
  end

  filter :id
  filter :normal_staff_name, as: :string
  filter :normal_corporation, as: :select, collection: -> {NormalCorporation.as_filter}
  filter :in_contract, as: :select, collection: ->{ [ ['活动', true], ['存档', false] ] }.call
  filter :contract_type, as: :select, collection: -> { LaborContract.contract_types_option }.call
  filter :has_social_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  filter :has_medical_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  filter :has_accident_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  preserve_default_filters!
  remove_filter :normal_staff

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :normal_staff, as: :select, collection: []
      f.input :normal_corporation, as: :select, collection: -> {NormalCorporation.as_filter}.call
      f.input :in_contract, as: :radio, collection: ->{ [ ['活动', true], ['存档', false] ] }.call
      f.input :contract_type, as: :select, collection: ->{ LaborContract.contract_types_option }.call
      f.input :contract_start_date, as: :datepicker
      f.input :contract_end_date, as: :datepicker
      f.input :arrive_current_company_at, as: :datepicker
      f.input :has_social_insurance, as: :radio, collection: ->{ [ ['有', true], ['无', false] ] }.call
      f.input :has_medical_insurance, as: :radio, collection: ->{ [ ['有', true], ['无', false] ] }.call
      f.input :has_accident_insurance, as: :radio, collection: ->{ [ ['有', true], ['无', false] ] }.call
      f.input :current_social_insurance_start_date, as: :datepicker
      f.input :current_medical_insurance_start_date, as: :datepicker
      f.input :social_insurance_base, as: :number, input_html: {value: 1861.15}
      f.input :medical_insurance_base, as: :number, input_html: {value: 3102}
      f.input :house_accumulation_base, as: :number, input_html: {value: 0}
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
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :normal_staff
      row :sub_company do |obj|
        sc = obj.normal_corporation.sub_company
        link_to sc.name, sub_company_path(sc)
      end
      row :normal_corporation do |obj|
        corp = obj.normal_corporation
        link_to corp.name, normal_corporation_path(corp)
      end
      row :in_contract do |obj|
        if obj.in_contract
          status_tag '活动', 'yes'
        else
          status_tag '存档', 'no'
        end
      end
      row :contract_type do |obj|
        obj.contract_type_i18n
      end

      displayed_columns = %i(id normal_staff_id normal_corporation_id in_contract contract_type)

      boolean_columns = resource.class.columns_of(:boolean)
      (resource_class.ordered_columns.map(&:to_sym) - displayed_columns).map do |field|
        if boolean_columns.include? field
          row(field) do |obj|
            if obj.send(field)
              status_tag resource.send(field).to_s
            else
              status_tag '无', 'no'
            end
          end
        else
          row field
        end
      end

    end
  end

  controller do
    def scoped_collection
      action = request.url.split('?').first.split('/').last rescue ''
      if action == 'labor_contracts'
        end_of_association_chain.includes(:normal_corporation)
      else
        end_of_association_chain
      end
    end
  end
end
