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

    panel "业务代理合同模板" do
      render partial: "shared/contract_template", locals: {sub_company: sub_company}
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
end
