ActiveAdmin.register LaborContract do
  belongs_to :normal_corporation, optional: true
  belongs_to :normal_staff, optional: true

  # include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 3

  config.sort_order = 'created_at_asc'

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (nsid=params['q']['normal_staff_id_eq']).present?
        ns = NormalStaff.where(id: nsid).first
        if ns.present?
          crumbs << link_to('员工信息', "/normal_staffs")
          crumbs << link_to(ns.name, "/normal_staffs?q[id_eq]=#{ns.id}")
        end
      elsif (ncid=params['q']['normal_corporation_id_eq']).present?
        nc = NormalCorporation.where(id: ncid).first
        if nc.present?
          crumbs << link_to('合作单位', "/normal_corporations")
          crumbs << link_to(nc.name, "/normal_corporations?q[id_eq]=#{nc.id}")
        end
      end
    end

    crumbs
  end

  scope "全部" do |record|
    record.all
  end
  scope "解除" do |record|
    record.archive
  end
  scope "活动" do |record|
    record.active
  end

  index row_class: ->elem { 'due_date' if elem.due? } do
    selectable_column

    column :id
    column :normal_staff, sortable: :normal_staff_id do |obj|
      ns = obj.normal_staff
      link_to ns.name, "/normal_staffs?q[id_eq]=#{ns.id}", target: '_blank'
    end
    column :sub_company, sortable: :id do |obj|
      sc = obj.normal_corporation.sub_company
      link_to sc.name, "/sub_companies/#{sc.id}", target: '_blank'
    end
    column :normal_corporation, sortable: :normal_corporation_id do |obj|
      corp = obj.normal_corporation
      link_to corp.name, "/normal_corporations?q[id_eq]=#{corp.id}", target: '_blank'
    end
    column :remark
    column :in_contract, sortable: :in_contract do |obj|
      if obj.in_contract
        status_tag '活动', 'yes'
      else
        status_tag '解除', 'no'
      end
    end
    column :contract_type do |obj|
      obj.contract_type_i18n
    end

    displayed_columns = %i(id normal_staff_id normal_corporation_id in_contract contract_type remark)

    (resource_class.ordered_columns.map(&:to_sym) - displayed_columns).map do |field|
      column field
    end

    actions
  end

  filter :id
  filter :normal_staff_name, as: :string
  filter :sub_company_in, as: :select, collection: -> {SubCompany.pluck(:name, :id)}
  filter :normal_corporation, as: :select, collection: -> {NormalCorporation.as_filter}
  filter :in_contract, as: :select, collection: ->{ [ ['活动', true], ['解除', false] ] }.call
  filter :contract_type, as: :select, collection: -> { LaborContract.contract_types_option(filter: true) }.call
  filter :has_social_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  filter :has_medical_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  filter :has_accident_insurance, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  preserve_default_filters!
  remove_filter :normal_staff
  remove_filter :sub_company
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :normal_staff_id, as: :hidden, input_html: {value: params[:q][:normal_staff_id_eq]}
      f.input :normal_corporation, as: :select, collection: -> {NormalCorporation.as_filter}.call
      f.input :in_contract, as: :radio, collection: ->{ [ ['活动', true], ['解除', false] ] }.call
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
      row :normal_staff do |obj|
        ns = obj.normal_staff
        link_to ns.name, "/normal_staffs?q[id_eq]=#{ns.id}", target: '_blank'
      end
      row :sub_company do |obj|
        sc = obj.normal_corporation.sub_company
        link_to sc.name, "/sub_companies/#{sc.id}", target: '_blank'
      end
      row :normal_corporation do |obj|
        corp = obj.normal_corporation
        link_to corp.name, "/normal_corporations?q[id_eq]=#{corp.id}", target: '_blank'
      end
      row :in_contract do |obj|
        if obj.in_contract
          status_tag '活动', 'yes'
        else
          status_tag '解除', 'no'
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

  # Batch actions
  batch_action :batch_edit, form: ->{ LaborContract.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => e
        failed << "操作失败<#{obj.name}>: #{obj.errors.full_messages.join(', ')} ; #{e.message}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  batch_action :batch_copy, form: ->{ LaborContract.batch_copy_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed, new_ids = [], []
    batch_action_collection.find(ids).each do |obj|
      begin
        new_ids << obj.copy_from(inputs).try(:id)
      rescue => e
        failed << "部分记录操作失败<#{obj.name}>: #{obj.errors.full_messages.join(', ')} ; #{e.message}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      query = new_ids.map{|n_id| "q[id_in][]=#{n_id}"}.join('&')
      redirect_to "/labor_contracts?#{query}", notice: "成功更新 #{ids.count} 条记录"
    end
  end

  controller do
    def scoped_collection
      action = request.url.split('?').first.split('/').last rescue ''
      if action == 'labor_contracts'
        end_of_association_chain# .includes(:normal_corporation)
      else
        end_of_association_chain
      end
    end
  end
end
