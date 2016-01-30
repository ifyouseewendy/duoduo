ActiveAdmin.register NormalStaff do
  belongs_to :normal_corporation, optional: true

  # include ImportSupport

  config.per_page = 30
  config.sort_order = 'updated_at_desc'

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 2

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (ncid=params['q']['normal_corporation_id_eq']).present?
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
  # scope "存档" do |record|
  #   record.not_in_service
  # end
  # scope "在职" do |record|
  #   record.in_service
  # end
  scope "有劳务关系" do |record|
    record.in_contract
  end
  scope "无劳务关系" do |record|
    record.not_in_contract
  end

  index do
    selectable_column

    column :id
    column :name
    column :identity_card
    column :sub_company, sortable: :sub_company_id do |obj|
      sc = obj.sub_company
      if sc.present?
        link_to sc.name, "/sub_companies/#{sc.id}", target: '_blank'
      end
    end
    column :normal_corporation, sortable: :normal_corporation_id do |obj|
      corporation = obj.normal_corporation
      if corporation.present?
        link_to corporation.name || '#', "/normal_corporations?q[id_eq]=#{corporation.id}", target: '_blank'
      end
    end
    column :labor_contracts, sortable: :id do |obj|
      ul do
        li link_to '劳务合同', "/labor_contracts?q[normal_staff_id_eq]=#{obj.id}", target: '_blank'
        li link_to '新建', "/labor_contracts/new?q[normal_staff_id_eq]=#{obj.id}", target: '_blank'
      end
    end
    column :salary_item_display, sortable: :id do |obj|
      ul do
        if obj.salary_items.count > 0
          li link_to("基础工资条", "/salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
        end
        if obj.guard_salary_items.count > 0
          li link_to(" 保安工资条", "/guard_salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
        end
        if obj.non_full_day_salary_items.count > 0
          li link_to(" 非全日制工资条", "/non_full_day_salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
        end
      end
    end

    # column :in_service
    column :in_contract, sortable: :in_contract do |obj|
      if obj.in_contract
        status_tag '有', :yes
      else
        status_tag '无', :no
      end
    end

    displayed_columns = [:id, :name, :identity_card, :sub_company_id, :normal_corporation_id, :in_service, :in_contract, :nest_index]

    (resource_class.ordered_columns.map(&:to_sym) - displayed_columns).map do |field|
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

  filter :sub_company
  filter :normal_corporation, as: :select, collection: -> {NormalCorporation.as_filter}
  # filter :in_service, as: :select, collection: ->{ [ ['在职', true], ['存档', false] ] }.call
  filter :in_contract, as: :select, collection: ->{ [ ['有', true], ['无', false] ] }.call
  filter :id
  filter :name
  filter :identity_card
  preserve_default_filters!
  remove_filter :nest_index
  remove_filter :salary_items
  remove_filter :guard_salary_items
  remove_filter :non_full_day_salary_items
  remove_filter :labor_contracts
  remove_filter :activities

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      f.input :identity_card, as: :string
      # f.input :in_service
      # f.input :in_contract
      f.input :account, as: :string
      f.input :account_bank, as: :string
      if request.url.split('/')[-1] == 'edit'
        f.input :birth, as: :datepicker
      end
      f.input :gender, as: :radio, collection: ->{ NormalStaff.genders_option }.call
      f.input :nation, as: :string
      f.input :grade, as: :string
      f.input :address, as: :string
      f.input :telephone, as: :string
      f.input :social_insurance_start_date, as: :datepicker
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :identity_card
      row :sub_company
      row :normal_corporation do |obj|
        corporation = obj.normal_corporation
        if corporation.present?
          link_to corporation.name || '#', "/normal_corporations?q[id_eq]=#{corporation.id}", target: '_blank'
        end
      end
      row :labor_contracts do |obj|
        link_to '劳务合同', "/labor_contracts?q[normal_staff_id_eq]=#{obj.id}", target: '_blank'
      end
      row :salary_item_display do |obj|
        ul do
          if obj.salary_items.count > 0
            li link_to("基础工资条", "/salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
          end
          if obj.guard_salary_items.count > 0
            li link_to(" 保安工资条", "/guard_salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
          end
          if obj.non_full_day_salary_items.count > 0
            li link_to(" 非全日制工资条", "/non_full_day_salary_items?q[normal_staff_id_eq]=#{obj.id}", target: '_blank' )
          end
        end
      end
      # row :in_service do |obj|
      #   if obj.in_service
      #     status_tag '在职', :yes
      #   else
      #     status_tag '存档', :no
      #   end
      # end
      row :in_contract do |obj|
        if obj.in_contract
          status_tag '有劳务关系', :yes
        else
          status_tag '无劳务关系', :no
        end
      end

      displayed_columns = [:id, :name, :identity_card, :sub_company_id, :normal_corporation_id, :in_service, :in_contract, :nest_index]

      (resource_class.ordered_columns.map(&:to_sym) - displayed_columns).map do |field|
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

  # sidebar '劳务合同', only: [:show] do
  #   ul do
  #     lc = normal_staff.labor_contract
  #     if lc.present?
  #       li link_to lc.name, normal_staff_labor_contract_path(normal_staff, lc), class: 'current_contract'
  #     end
  #
  #     li link_to "全部合同", normal_staff_labor_contracts_path(normal_staff)
  #   end
  # end

  # Batch actions
  batch_action :batch_edit, form: ->{ NormalStaff.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => _
        failed << "操作失败<#{obj.name}>: #{obj.errors.full_messages.join(', ')}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:sub_company).includes(:normal_corporation)
    end
  end
end
