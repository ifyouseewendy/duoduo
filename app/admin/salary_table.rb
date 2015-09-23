ActiveAdmin.register SalaryTable do

  menu \
    label: I18n.t("activerecord.models.salary_table"),
    priority: 4

  permit_params *SalaryTable.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  index do
    selectable_column
    SalaryTable.ordered_columns(without_foreign_keys: true).map(&:to_sym).map do |field|
      column field
    end
    column :corporation, sortable: ->(obj){ obj.corporation.name }
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :normal_corporation, as: :select
      f.input :engineering_corporation, as: :select
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
