ActiveAdmin.register SubCompany do
  menu priority: 2

  config.batch_actions = false
  config.filters = false
  config.sort_order = 'id_asc'
  config.per_page = 20

  index download_links: false do
    selectable_column

    column :name
    column :created_at
    column :updated_at

    column :link do |obj|
      link_to "业务合作单位", "/normal_corporations?q[sub_company_id_eq]=#{obj.id}", target: '_blank'
    end
    column :link do |obj|
      link_to "业务员工信息", "/normal_staffs?q[sub_company_id_eq]=#{obj.id}", target: '_blank'
    end
    column :link do |obj|
      link_to "业务劳务合同", "/labor_contracts?q[sub_company_in]=#{obj.id}", target: '_blank'
    end

    unless current_active_admin_user.business?
      column :link do |obj|
        if obj.has_engineering_relation
          link_to "工程客户", "engineering_customers?q[sub_company_in]=#{obj.id}", target: '_blank'
        end
      end
      column :link do |obj|
        if obj.has_engineering_relation
          link_to "工程合作单位", "/engineering_corps?q[sub_company_in]=#{obj.id}", target: '_blank'
        end
      end
      column :link do |obj|
        if obj.has_engineering_relation
          link_to "工程项目", "/engineering_projects?q[sub_company_id_eq]=#{obj.id}", target: '_blank'
        end
      end
    end

    actions do |obj|
    end
  end

  permit_params { resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name, as: :string
      f.input :has_engineering_relation, as: :boolean
    end

    f.actions
  end

  show do
    boolean_columns = resource.class.columns_of(:boolean)
    columns = resource.class.ordered_columns - %i(id engi_contract_template engi_protocol_template)
    attributes_table do
      columns.map do |field|
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          row field
        end
      end
    end

    panel "模板" do
      # panel "业务代理合同" do
      #   render partial: "sub_companies/contract_template", \
      #     locals: {
      #       company: sub_company,
      #       templates: sub_company.contract_templates,
      #     }
      # end

      if resource.has_engineering_relation
        panel "工程项目 - 劳务派遣协议" do
          render partial: "sub_companies/engi_template_display",\
            locals: {
              company: sub_company,
              field: :engi_contract_template
            }
          render partial: "sub_companies/engi_template_upload",\
            locals: {
              company: sub_company,
              field: :engi_contract_template,
              override: true
            }
        end
        panel "工程项目 - 代发劳务费协议" do
          render partial: "sub_companies/engi_template_display",\
            locals: {
              company: sub_company,
              field: :engi_protocol_template
            }
          render partial: "sub_companies/engi_template_upload",\
            locals: {
              company: sub_company,
              field: :engi_protocol_template,
              override: true
            }
        end
      end
    end

    active_admin_comments
  end

  member_action :remove_template, method: :delete do
    sub_company = SubCompany.find params.require(:id)

    begin
      field = params[:field]
      raise "指定了错误的 field: #{field}"\
        unless %i(engi_contract_template engi_protocol_template).include?(field.to_sym)

      sub_company.public_send("remove_#{field}!")
      sub_company.save!

      redirect_to sub_company_path(sub_company), notice: "成功删除模板"
    rescue => e
      redirect_to sub_company_path(sub_company), alert: "删除失败：#{e.message}"
    end
  end

  member_action :add_template, method: :post do
    sub_company = SubCompany.find params.require(:id)

    begin
      field = params[:field]
      raise "指定了错误的 field: #{field}"\
        unless %i(engi_contract_template engi_protocol_template).include?(field.to_sym)

      file = params[:file]
      raise "添加失败：未找到文件" if file.nil?

      path = Pathname(file.path)
      to = path.dirname.join(file.original_filename)
      path.rename(to)

      sub_company.public_send("#{field}=", File.open(to))
      sub_company.save!

      redirect_to sub_company_path(sub_company), notice: "成功添加模板： #{to.basename}"
    rescue => e
      redirect_to sub_company_path(sub_company), alert: "添加失败：#{e.message}"
    end
  end

end
