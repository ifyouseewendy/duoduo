ActiveAdmin.register SubCompany do
  menu priority: 2

  config.batch_actions = false
  config.filters = false
  config.sort_order = 'id_asc'

  index download_links: false do
    selectable_column

    column :id
    column :name
    column :created_at
    column :updated_at

    column :link do |obj|
      link_to "普通合作单位", "/normal_corporations?utf8=✓&q%5Bsub_companies_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :link do |obj|
      link_to "普通员工信息", "/normal_staffs?utf8=✓&q%5Bsub_company_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :link do |obj|
      link_to "劳务合同", "/labor_contracts?utf8=✓&q%5Bsub_company_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
    end
    column :link do |obj|
      if obj.has_engineering_relation
        link_to "工程合作单位", "/normal_corporations?utf8=✓&q%5Bsub_companies_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
      end
    end
    column :link do |obj|
      if obj.has_engineering_relation
        link_to "工程员工信息", "/engineering_staffs?utf8=✓&q%5Bsub_company_id_eq%5D=#{obj.id}&commit=过滤&order=id_desc"
      end
    end

    actions do |obj|
    end
  end

  permit_params *SubCompany.ordered_columns(without_base_keys: true, without_foreign_keys: true)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :name, as: :string
      f.input :has_engineering_relation, as: :boolean
    end

    f.actions
  end

  show do
    boolean_columns = SubCompany.columns_of(:boolean)
    attributes_table do
      SubCompany.ordered_columns.map(&:to_sym).map do |field|
        next if field == :contract_templates
        if boolean_columns.include? field
          row(field) { status_tag resource.send(field).to_s }
        else
          row field
        end
      end
    end

    panel "模板" do
      panel "业务代理合同" do
        render partial: "sub_companies/contract_template", locals: {sub_company: sub_company}
      end

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

  member_action :remove_contract_template, method: :delete do
    sub_company = SubCompany.find params.require(:id)

    begin
      sub_company.remove_contract_template_at params.require(:contract_template_id).to_i

      redirect_to sub_company_path(sub_company), notice: "成功删除业务合同模板"
    rescue => e
      redirect_to sub_company_path(sub_company), alert: "删除失败：#{e.message}"
    end
  end

  member_action :add_contract_template, method: :post do
    sub_company = SubCompany.find params.require(:id)

    begin
      file = params.require(:sub_company).require(:contract_template)
      raise "添加失败：未找到文件" if file.nil?

      path = Pathname(file.path)
      to = path.dirname.join(file.original_filename)
      path.rename(to)

      sub_company.add_contract_template to

      redirect_to sub_company_path(sub_company), notice: "成功添加业务合同模板： #{to.basename}"
    rescue => e
      redirect_to sub_company_path(sub_company), alert: "添加失败：#{e.message}"
    end
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
