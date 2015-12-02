ActiveAdmin.register SalaryTable do
  belongs_to :normal_corporation, optional: true

  menu \
    parent: I18n.t("activerecord.models.normal_business"),
    priority: 4

  permit_params *SalaryTable.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  index do
    selectable_column
    (SalaryTable.ordered_columns(without_foreign_keys: true) - [:remark]).map(&:to_sym).map do |field|
      if %i(lai_table daka_table).include? field
        column field do |obj|
          link_to obj.send("#{field}_identifier"), obj.send(field).url
        end
      else
        column field
      end
    end
    column :corporation, sortable: ->(obj){ obj.corporation.name }

    actions do |st|
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "发票", "/invoices?utf8=✓&q%5Binvoicable_id_eq%5D=#{st.id}&invoicable_type%5D=#{st.class.name}&commit=过滤&order=id_desc", class: "member_link expand_table_action_width"
      item "工资条", salary_table_salary_items_path(st), class: "member_link"
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :normal_corporation, as: :select
      f.input :name, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      SalaryTable.ordered_columns(without_foreign_keys: true).map(&:to_sym).map do |field|
        row field
      end
      row :corporation
    end
  end
end
