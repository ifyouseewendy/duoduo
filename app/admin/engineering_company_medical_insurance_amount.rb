ActiveAdmin.register EngineeringCompanyMedicalInsuranceAmount do
  menu \
    parent: I18n.t("activerecord.models.settings"),
    priority: 5

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false
  config.sort_order = 'id_asc'

  permit_params -> { @resource.ordered_columns }

  index download_links: false do
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true).map do |field|
      column field
    end
    actions defaults: false do |obj|
      item "编辑", edit_engineering_company_medical_insurance_amount_path(obj)
    end
  end

  action_item :add_grade do
    link_to '添加条目', new_engineering_company_medical_insurance_amount_path
  end

  sidebar "说明" do
    ul do
      li span "本页条目用于计算工程工资表中的'医保医疗工伤生育保险单位7.9%'，根据工程项目起止时间到此表中获取应缴保险金额"
    end
  end
end
