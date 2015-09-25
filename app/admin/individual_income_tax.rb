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
    link_to "编辑", edit_individual_income_tax_basis_path(IndividualIncomeTaxBase.instance), class: 'update_iit_base'
  end
  sidebar "个税计算器", partial: 'calculator'
  sidebar "说明" do
    ol do
      li span "本页个税计算器会用于计算工资表中的个税，如有问题请及时反馈。"
      li span "个税基数以及各级别税率均可通过'编辑' 按钮进行更新。"
      li '参考' do
        ul do
          li link_to("个人所得税率", "http://baike.baidu.com/link?url=NwQI9QItofm_p2bpNRXk8fH6xEZX0wR2KpH-qEVMRXehaYmngaU7Rt5opJc7lmR4yIyHCRRpP87Ui77wRl5HRq")
          li link_to("年终奖个税计算", "http://laodongfa.yjbys.com/zixun/196218.html")
        end
      end
    end
  end

  collection_action :calculate, method: :post do
    salary, bonus = params.values_at(:salary, :bonus).map(&:to_f)

    render json: {result: IndividualIncomeTax.calculate(salary: salary, bonus: bonus)}
  end
end
