ActiveAdmin.register EngineeringNormalSalaryItem do
  menu false

  breadcrumb do
    if params['q'].present?
      st = EngineeringSalaryTable.find(params['q']['salary_table_id_eq'])
      [
        link_to(st.engineering_project.name, engineering_project_path(st.engineering_project) ),
        link_to(st.name, engineering_salary_table_path(st) )
      ]
    else
      []
    end
  end

  index do
    selectable_column

    EngineeringNormalSalaryItem.ordered_columns(without_foreign_keys: true).each do |field|
      column field
    end

    actions
  end
end
