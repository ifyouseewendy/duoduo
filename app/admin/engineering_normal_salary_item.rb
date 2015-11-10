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

    column :id
    column :name, sortable: ->(obj){ obj.engineering_staff.name } do |obj|
      staff = obj.engineering_staff
      link_to staff.name, engineering_staff_path(staff)
    end
    (EngineeringNormalSalaryItem.ordered_columns(without_foreign_keys: true) - [:id]).each do |field|
      column field
    end

    actions
  end

  preserve_default_filters!
  remove_filter :engineering_staff

  permit_params *EngineeringNormalSalaryItem.ordered_columns(without_base_keys: true, without_foreign_keys: false)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :social_insurance, as: :number
      f.input :medical_insurance, as: :number
      f.input :salary_in_fact, as: :number
      f.input :remark, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name do |obj|
        staff = obj.engineering_staff
        link_to staff.name, engineering_staff_path(staff)
      end
      row :salary_table do |obj|
        st = obj.salary_table
        link_to st.name, engineering_salary_table_path(st)
      end
      row :engineering_project do |obj|
        pr = obj.salary_table.engineering_project
        link_to pr.name, engineering_project_path(pr)
      end
      (EngineeringNormalSalaryItem.ordered_columns(without_foreign_keys: true) - [:id]).each do |field|
        row field
      end
    end
    active_admin_comments
  end

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options[:salary_table_id] = params[:q][:salary_table_id_eq] rescue nil

    file = EngineeringNormalSalaryItem.export_xlsx(options: options)
    send_file file, filename: file.basename
  end

end
