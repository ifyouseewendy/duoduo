ActiveAdmin.register IndividualIncomeTax do
  menu \
    parent: I18n.t("activerecord.models.settings"),
    priority: 1

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false
  config.sort_order = 'grade_asc'

  index download_links: false do
    IndividualIncomeTax.ordered_columns(without_base_keys: true, without_foreign_keys: true).map do |field|
      column field
    end
    actions defaults: false do |iit|
      item "编辑", edit_individual_income_tax_path(iit)
    end
  end

  action_item :add_grade do
    link_to '添加级数', new_individual_income_tax_path
  end

  sidebar "个税基数" do
    span IndividualIncomeTaxBase.instance.base
    link_to "更新", edit_individual_income_tax_basis_path(IndividualIncomeTaxBase.instance), class: 'update_iit_base'
  end
  sidebar "个税计算器", partial: 'calculator'

  collection_action :calculate, method: :post do
    salary, bonus = params.values_at(:salary, :bonus).map(&:to_i)

    render json: {result: 100}
  end
end
