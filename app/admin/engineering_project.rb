ActiveAdmin.register EngineeringProject do
  belongs_to :engineering_customer, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 3

  breadcrumb do
    crumbs = []

    if params['q'].present?
      if (cid=params['q']['customer_id_eq']).present?
        customer = EngineeringCustomer.where(id: cid).first
        if customer.present?
          crumbs << link_to('客户', '/engineering_customers')
          crumbs << link_to(customer.display_name, "/engineering_customers?q[id_eq]=#{customer.id}")
        end
      elsif (sid=params['q']['staffs_id_eq']).present?
        staff = EngineeringStaff.where(id: sid).first
        if staff.present?
          crumbs << link_to(staff.name, "/engineering_staffs?q[id_eq]=#{staff.id}")
        end
      end
    end

    crumbs
  end

  # Index
  scope "全部" do |record|
    record.all
  end
  scope "存档" do |record|
    record.archive
  end
  scope "活动" do |record|
    record.active
  end

  index has_footer: true do
    selectable_column

    sum_fields = resource_class.sum_fields+[:income_amount, :outcome_amount]
    sum = sum_fields.reduce({}) do |ha, field|
      ha[field] = collection.sum(field)
      ha
    end

    column :nest_index
    column :name, footer: '合计'
    column :customer, sortable: :id do |obj|
      link_to obj.customer.display_name, "/engineering_customers?utf8=✓&q%5Bnest_index_equals%5D=#{obj.customer.nest_index}&commit=过滤", target: '_blank'
    end
    column :sub_company, sortable: :id do |obj|
      sc = obj.sub_company
      link_to sc.name, sub_company_path(sc), target: '_blank'
    end
    column :corporation, sortable: :id do |obj|
      if obj.corporation.nil?
        link_to '', '无'
      else
        link_to obj.corporation.name, engineering_corp_path(obj.corporation), target: '_blank'
      end
    end
    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end
    (resource_class.ordered_columns(without_foreign_keys: true) - [:id, :nest_index, :name, :status]).each do |field|
      if resource_class.nest_fields.include? field
        opt = {}
        opt = {footer: sum[field]} if [:outcome_amount, :income_amount].include?(field)
        column field, opt do |obj|
          data = obj.send(field)
          if data.count > 1
            options = data.zip( data.count.downto(1) ).reduce([]){|ar, (e,i)| ar << ["第#{i}批 - #{e}", i] }
            select_tag(nil, options_for_select(options) )
          else
            data[0]
          end
        end
      elsif resource_class.sum_fields.include? field
        column field, footer: sum[field]
      else
        column field
      end
    end

    column :staff_detail, sortable: :updated_at do |obj|
      ul do
        li( link_to "查看", "/engineering_staffs?utf8=✓&q%5Bprojects_id_eq%5D=#{obj.id}&commit=过滤", target: '_blank' )
        li( link_to "添加", "#", class: "add_staffs_link" )
        li( link_to "导入", "/engineering_staffs/import_new?project_id=#{obj.id}", target: '_blank' )
        li( link_to "删除", "#", class: "remove_staffs_link" )
      end
    end
    column :salary_table_detail, sortable: :updated_at do |obj|
      ul do
        li( link_to "查看", "/engineering_salary_tables?utf8=✓&q%5Bproject_id_eq%5D=#{obj.id}&commit=过滤", target: '_blank' )
        li( link_to "自动生成", auto_generate_salary_table_engineering_project_path(obj), target: '_blank' )
        li( link_to "导入", "/engineering_salary_tables/import_new?project_id=#{obj.id}", target: '_blank' )
      end
    end

    actions do |obj|
      # text_node "&nbsp;|&nbsp;&nbsp;".html_safe

      # text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      # item "生成工资表", "#", class: "generate_salary_table_link expand_table_action_width_large"
      # text_node "&nbsp;&nbsp;".html_safe
      # item "查看工资表", engineering_project_engineering_salary_tables_path(obj)
    end
  end

  filter :status, as: :check_boxes, collection: ->{ EngineeringProject.statuses_option(filter: true) }
  filter :customer
  filter :corporation
  filter :sub_company, as: :select, collection: ->{ SubCompany.hr.pluck(:name, :id) }
  filter :nest_index
  preserve_default_filters!
  remove_filter :staffs
  remove_filter :salary_tables
  remove_filter :contract_files
  remove_filter :income_items
  remove_filter :outcome_items
  remove_filter :activities

  permit_params do
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: false) \
      + [{
        income_items_attributes: [:id, :date, :amount, :remark, :_destroy],
        outcome_items_attributes: [:id, :date, :amount, :_destroy, :remark, each_amount: [], persons: [], bank: [], address: [], account: [] ]
      }]
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    tabs do
      tab "基本信息" do
        f.inputs do
          f.input :name, as: :string
          f.input :customer, as: :select, collection: ->{ EngineeringCustomer.as_option }.call
          f.input :nest_index, as: :number, hint: '根据客户自动分配项目编号'
          f.input :corporation
          f.input :sub_company, as: :select, collection: -> { SubCompany.hr }.call
          f.input :status, as: :radio, collection: ->{ EngineeringProject.statuses_option }.call
          f.input :start_date, as: :datepicker
          f.input :project_start_date, as: :datepicker
          f.input :project_end_date, as: :datepicker
          # f.input :project_range, as: :string
          f.input :project_amount, as: :number
          f.input :admin_amount, as: :number
          f.input :proof, as: :string
          f.input :already_sign_dispatch, as: :boolean
          f.input :remark, as: :text
        end
      end
      tab "来款记录" do
        f.inputs do
          f.has_many :income_items, heading: '来款记录', allow_destroy: true, new_record: true do |a|
            a.input :date, as: :datepicker
            a.input :amount, as: :number
            a.input :remark, as: :string
          end
        end
      end
      tab "回款记录" do
        f.inputs do
          f.has_many :outcome_items, heading: '回款记录', allow_destroy: true, new_record: true do |a|
            a.input :date, as: :datepicker
            a.input :amount, as: :number
            a.input :persons, as: :string, hint: '姓名需要以空格分隔，例如：张三 李四'
            a.input :each_amount, as: :string, hint: '与姓名对应，以空格分隔'
            a.input :bank, as: :string, hint: '与姓名对应，以空格分隔'
            a.input :account, as: :string, hint: '与姓名对应，以空格分隔'
            a.input :address, as: :string, hint: '与姓名对应，以空格分隔'
            a.input :remark, as: :string
          end
        end
      end
    end

    f.actions
  end

  show do
    tabs do
      tab "基本信息" do
        attributes_table do
          row :nest_index
          row :name
          row :staffs do |obj|
            link_to "用工明细", "/engineering_staffs?utf8=✓&q%5Bengineering_projects_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc", target: '_blank'
          end
          row :customer do |obj|
            link_to obj.customer.display_name, engineering_customer_path(obj.customer), target: '_blank'
          end
          row :corporation do |obj|
            if obj.corporation.nil?
              link_to '', '#'
            else
              link_to obj.corporation.name, engineering_corp_path(obj.corporation), target: '_blank'
            end
          end
          row :sub_company do |obj|
            sc = obj.sub_company
            link_to sc.name, sub_company_path(sc), target: '_blank'
          end
          row :status do |obj|
            status_tag obj.status_i18n, (obj.active? ? :yes : :no)
          end

          boolean_columns = resource.class.columns_of(:boolean)
          (
            resource.class.ordered_columns(without_foreign_keys: true) \
            - [:id, :nest_index, :name, :status, :income_date, :income_amount, :outcome_date, :outcome_referee, :outcome_amount]
          ).map(&:to_sym).map do |field|
            if boolean_columns.include? field
              row(field) { status_tag resource.send(field).to_s }
            elsif resource_class.nest_fields.include? field
              row field do |obj|
                data = obj.send(field)
                if data.count > 1
                  options = data.zip( data.count.downto(1) ).reduce([]){|ar, (e,i)| ar << ["第#{i}批 - #{e}", i] }
                  select_tag(nil, options_for_select(options) )
                else
                  data[0]
                end
              end
            else
              row field
            end
          end
        end
        panel "劳务派遣协议（合同）" do
          render partial: 'engineering_projects/contract_list', locals: { contract_files: resource.contract_files.normal, engineering_project: resource, role: :normal }
          tabs do
            tab '手动上传' do
              render partial: "engineering_projects/contract_upload", \
                locals: {
                  project: resource,
                  role: :normal
                }
            end
            tab '自动生成' do
              render partial: "engineering_projects/contract_generate_contract", \
                locals: {
                  project: resource,
                  role: :normal
                }
            end
          end
        end

      end

      tab "来款记录" do
        resource.income_items.each_with_index do |oi, idx|
          panel "第#{idx+1}次来款" do
            attributes_table_for oi do
              row :date
              row :amount
              row :remark
            end
          end
        end
      end

      tab "回款记录" do
        resource.outcome_items.each_with_index do |oi, idx|
          panel "第#{idx+1}次来款" do
            attributes_table_for oi do
              row :date
              row :amount
              row :persons do |obj|
                obj.persons.join(' ')
              end
              row :each_amount do |obj|
                obj.each_amount.join(' ')
              end
              row :bank do |obj|
                obj.bank.join(' ')
              end
              row :account do |obj|
                obj.account.join(' ')
              end
              row :address do |obj|
                obj.address.join(' ')
              end
              row :remark
            end
          end
          panel "代发劳务费协议" do
            render partial: 'engineering_projects/contract_list', locals: { contract_files: oi.contract_files  }
            tabs do
              tab '手动上传' do
                render partial: "engineering_projects/contract_upload", \
                  locals: {
                    project: resource,
                    role: :proxy,
                    outcome_item: oi,
                  }
              end
              tab '自动生成' do
                render partial: "engineering_projects/contract_generate_protocol", \
                  locals: {
                    project: resource,
                    role: :proxy,
                    outcome_item: oi
                  }
              end
            end
          end
        end

      end
    end

    active_admin_comments
  end

  # Batch actions
  batch_action :batch_edit, form: ->{ EngineeringProject.batch_form_fields } do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    failed = []
    batch_action_collection.find(ids).each do |obj|
      begin
        obj.update_attributes!(inputs)
      rescue => _
        failed << "操作失败<编号#{obj.nest_index}>: #{obj.errors.full_messages.join(', ')}"
      end
    end

    if failed.present?
      redirect_to :back, alert: failed.join('; ')
    else
      redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
    end
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options.update(params[:q]) if params[:q].present?

    file = EngineeringProject.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

  collection_action :query_all do
    stats = EngineeringProject.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end
    render json: stats
  end

  collection_action :query_staff do
    staff = EngineeringStaff.find( params[:staff_id] )

    stats = staff.projects.select(:id, :name).reduce([]) do |ar, ele|
      ar << {
        id: ele.id,
        name: ele.name
      }
    end

    render json: stats
  end

  # Member actions
  member_action :add_staffs, method: :post do
    project = EngineeringProject.find(params[:id])
    staffs = params[:engineering_staff_ids].map{|id| EngineeringStaff.where(id: id).first}.compact

    messages = []
    staffs.each do |staff|
      begin
        project.staffs << staff
        # messages << "操作成功，<#{staff.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    if messages.blank?
      render json: {message: '操作成功' }
    else
      render json: {message: messages.join('；') }
    end
  end

  member_action :remove_staffs, method: :post do
    project = EngineeringProject.find(params[:id])
    staff_ids = project.staffs.select(:id).map(&:id) - (params[:engineering_staff_ids].reject(&:blank?).map(&:to_i) rescue [])
    staffs =  staff_ids.map{|id| EngineeringStaff.where(id: id).first}.compact

    messages = []
    staffs.each do |staff|
      begin
        project.staffs.delete staff
        # messages << "操作成功，员工<#{staff.name}>已离开项目<#{project.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    if messages.blank?
      render json: {message: '操作成功' }
    else
      render json: {message: messages.join('；') }
    end
  end

  member_action :available_staff_count do
    project = EngineeringProject.find( params[:id] )
    own_staff_count = project.staffs.count

    customer = project.customer
    other_staff_count = customer.free_staffs( *project.range ).count

    render json: { count: own_staff_count + other_staff_count  }
  end

  member_action :generate_salary_table, method: :post do
    project = EngineeringProject.find(params[:id])

    begin
      if 'EngineeringNormalSalaryTable' == params[:salary_type]
        project.generate_salary_table(need_count: params[:need_count].to_i)
      elsif 'EngineeringNormalWithTaxSalaryTable' == params[:salary_type]
        project.generate_salary_table_with_tax(file: params[:salary_file])
      else
        project.generate_salary_table_big(url: params[:salary_url])
      end

      render json: {status: 'succeed', url: engineering_project_engineering_salary_tables_path(project) }
    rescue => e
      render json: {status: 'failed', message: e.message }
    end
  end

  member_action :auto_generate_salary_table do
    begin
      resource.auto_generate_salary_table
      redirect_to engineering_project_engineering_salary_tables_path(resource), notice: "成功自动生成工资表"
    rescue => e
      redirect_to :back, alert: "生成失败 #{e.message}"
    end
  end

  controller do
    before_action :wrap_params, only: :update
    before_filter :set_page_title, only: [:index]

    def set_page_title
      if params['q'].present?
        if params['q']['staffs_id_eq'].present?
          @page_title = '所属项目'
        end
      else
        @page_title = '项目汇总'
      end
    end

    def scoped_collection
      end_of_association_chain
        .includes(:customer)
        .includes(:sub_company)
        .includes(:corporation)
        .includes(:income_items)
        .includes(:outcome_items)
    end
    private

      def wrap_params
        return if params[:engineering_project][:outcome_items_attributes].blank?

        params[:engineering_project][:outcome_items_attributes].each do |k, v|
          v[:persons] = v[:persons].split.map(&:strip)
          v[:each_amount] = v[:each_amount].split.map(&:strip)
          v[:bank] = v[:bank].split.map(&:strip)
          v[:account] = v[:account].split.map(&:strip)
          v[:address] = v[:address].split.map(&:strip)
        end
      end
  end

end
