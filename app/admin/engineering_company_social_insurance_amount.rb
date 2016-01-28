ActiveAdmin.register EngineeringCompanySocialInsuranceAmount do
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 8

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false
  config.sort_order = 'id_asc'

  permit_params { resource_class.ordered_columns }

  index download_links: false do
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true).map do |field|
      column field
    end
    actions defaults: false do |obj|
      item "编辑", edit_engineering_company_social_insurance_amount_path(obj)
      text_node "&nbsp".html_safe
      item "删除", engineering_company_social_insurance_amount_path(obj), method: :delete
    end
  end

  action_item :add_grade do
    link_to '添加条目', new_engineering_company_social_insurance_amount_path
  end

  sidebar "说明" do
    ul do
      li span "本页条目用于计算工程工资表中的'社保养老失业保险单位22%'，根据工程项目起止时间到此表中获取应缴保险金额"
      li span "结束日期可为空，用来标识没有结束日期，一直有效"
    end
  end
end
