ActiveAdmin.register EngineeringProject do
  belongs_to :engineering_customer, optional: true

  # include ImportSupport

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 3

  index do
    selectable_column

    column :id
    column :name
    column :staffs, sortable: :id do |obj|
      link_to "员工列表", "/engineering_staffs?utf8=✓&q%5Bengineering_projects_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :customer, sortable: :id do |obj|
      link_to obj.customer.name, engineering_customer_path(obj.customer)
    end
    column :corporation, sortable: :id do |obj|
      if obj.corporation.nil?
        link_to '', '#'
      else
        link_to obj.corporation.name, engineering_corp_path(obj.corporation)
      end
    end
    column :sub_companies, sortable: :id do |obj|
      ul do
        obj.customer.sub_companies.map do |sc|
          li (link_to sc.name, sub_company_path(sc))
        end
      end
    end
    (resource_class.ordered_columns(without_foreign_keys: true) - [:id, :name]).each do |field|
      if resource_class.nest_fields.include? field
        column field do |obj|
          data = obj.send(field)
          if data.count > 1
            options = data.zip( data.count.downto(1) ).reduce([]){|ar, (e,i)| ar << ["第#{i}批 - #{e}", i] }
            select_tag(nil, options_for_select(options) )
          else
            data[0]
          end
        end
      elsif field == :status
        column field do |obj|
          status_tag obj.status_i18n, (obj.active? ? :yes : :no)
        end
      else
        column field
      end
    end

    actions do |obj|
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "添加员工", "#", class: "add_staffs_link"
      text_node "&nbsp;&nbsp;".html_safe
      item "删除员工", "#", class: "remove_staffs_link"

      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "生成工资表", "#", class: "generate_salary_table_link expand_table_action_width_large"
      text_node "&nbsp;&nbsp;".html_safe
      item "查看工资表", engineering_project_engineering_salary_tables_path(obj)
    end
  end

  filter :sub_company_in, as: :select, collection: ->{ SubCompany.hr.pluck(:name, :id) }
  filter :status, as: :check_boxes, collection: ->{ EngineeringProject.statuses_option }
  filter :income_items_date, as: :date_range
  filter :income_items_amount, as: :numeric
  filter :outcome_items_date, as: :date_range
  filter :outcome_items_amount, as: :numeric
  # filter :outcome_items_persons, as: :string
  preserve_default_filters!
  remove_filter :staffs
  remove_filter :salary_tables
  remove_filter :contract_files
  remove_filter :income_items
  remove_filter :outcome_items

  permit_params ->{
    @resource.ordered_columns(without_base_keys: true, without_foreign_keys: false) \
    + [{ income_items_attributes: [:id, :date, :amount, :remark, :_destroy], outcome_items_attributes: [:id, :date, :amount, :_destroy, :remark, persons: [], bank: [], address: [], account: [] ] }]
  }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    tabs do
      tab "基本信息" do
        f.inputs do
          f.input :customer, collection: ->{ EngineeringCustomer.all }
          f.input :corporation, collection: ->{ EngineeringCorp.all }
          f.input :name, as: :string
          f.input :start_date, as: :datepicker
          f.input :project_start_date, as: :datepicker
          f.input :project_end_date, as: :datepicker
          f.input :project_range, as: :string
          f.input :project_amount, as: :number
          f.input :admin_amount, as: :number
          f.input :proof, as: :string
          f.input :already_sign_dispatch, as: :boolean
          f.input :status, as: :radio, collection: ->{ EngineeringProject.statuses_option }
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
          row :id
          row :name
          row :staffs do |obj|
            link_to "员工列表", "/engineering_staffs?utf8=✓&q%5Bengineering_projects_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
          end
          row :customer do |obj|
            link_to obj.customer.name, engineering_customer_path(obj.customer)
          end
          row :corporation do |obj|
            if obj.corporation.nil?
              link_to '', '#'
            else
              link_to obj.corporation.name, engineering_corp_path(obj.corporation)
            end
          end

          boolean_columns = resource.class.columns_of(:boolean)
          (
            resource.class.ordered_columns(without_foreign_keys: true) \
            - [:id, :name, :income_date, :income_amount, :outcome_date, :outcome_referee, :outcome_amount]
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
            elsif field == :status
              row field do |obj|
                status_tag obj.status_i18n, (obj.active? ? :yes : :no)
              end
            else
              row field
            end
          end
        end
        panel "劳务派遣协议" do
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
              row :bank do |obj|
                obj.bank.join(' ')
              end
              row :account do |obj|
                obj.account.join(' ')
              end
              row :address do |obj|
                obj.address.join(' ')
              end
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

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?

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
        messages << "操作成功，项目<#{project.name}>已分配给<#{staff.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
  end

  member_action :remove_staffs, method: :post do
    project = EngineeringProject.find(params[:id])
    staff_ids = project.staffs.select(:id).map(&:id) - (params[:engineering_staff_ids].reject(&:blank?).map(&:to_i) rescue [])
    staffs =  staff_ids.map{|id| EngineeringStaff.where(id: id).first}.compact

    messages = []
    staffs.each do |staff|
      begin
        project.staffs.delete staff
        messages << "操作成功，员工<#{staff.name}>已离开项目<#{project.name}>"
      rescue => e
        messages << "操作失败，#{e.message}"
      end
    end

    render json: {message: messages.join('；') }
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

  controller do
    before_action :wrap_params, only: :update

    private

      def wrap_params
        return if params[:engineering_project][:outcome_items_attributes].blank?

        params[:engineering_project][:outcome_items_attributes].each do |k, v|
          v[:persons] = v[:persons].split.map(&:strip)
          v[:bank] = v[:bank].split.map(&:strip)
          v[:account] = v[:account].split.map(&:strip)
          v[:address] = v[:address].split.map(&:strip)
        end
      end
  end
end
