ActiveAdmin.register GuardSalaryItem do
  belongs_to :guard_salary_table

  breadcrumb do
    [
      link_to(guard_salary_table.corporation.name, normal_corporation_path(guard_salary_table.corporation) ),
      link_to(guard_salary_table.name, guard_salary_table_guard_salary_items_path(guard_salary_table) )
    ]
  end

  # Import
  include ImportSupport

  sidebar '参考', only: :import_new do
    para "#{normal_corporation.name} 中包含 #{NormalStaff.where(normal_corporation_id: normal_corporation.id).count} 名员工，分别为"
    ul do
      NormalStaff.where(normal_corporation_id: normal_corporation.id).each do |staff|
        li link_to(staff.name, normal_staff_path(staff))
      end
    end
  end

  # Index
  index do
    selectable_column

    column :id
    column :staff_attribute, sortable: :id
    column :staff_account, sortable: ->(obj){ obj.staff_account }
    column :normal_staff, sortable: :normal_staff_id
    column :guard_salary_table, sortable: :guard_salary_table_id

    (GuardSalaryItem.ordered_columns(without_foreign_keys: true) - [:id]).each do |field|
      column field
    end

    actions
  end

  # Batch actions
  batch_action :batch_edit, form: GuardSalaryItem.batch_form_fields do |ids|
    inputs = JSON.parse(params['batch_action_inputs']).with_indifferent_access

    batch_action_collection.find(ids).each do |obj|
      obj.update(inputs)
    end

    redirect_to :back, notice: "成功更新 #{ids.count} 条记录"
  end
end
