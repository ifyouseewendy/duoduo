ActiveAdmin.register InsuranceFundRate do
  actions :all, except: [:new, :create, :destroy]

  menu \
    parent: I18n.t("activerecord.models.settings"),
    priority: 3

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false

  permit_params ->{ @resource.ordered_columns }

  index download_links: false do
    resource_class.ordered_columns(without_base_keys: true, without_foreign_keys: true).map do |field|
      column field
    end
    actions defaults: false do |ifr|
      item "编辑", edit_insurance_fund_rate_path(ifr)
    end
  end

  sidebar "说明" do
    ol do
      li span "五险一金缴费比例会用于计算工资表中的五险一金，如有问题请及时反馈。"
      li span "各比例均可通过'编辑' 按钮进行更新。"
    end
  end
end
