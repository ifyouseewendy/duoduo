ActiveAdmin.register EngineeringSalaryTable do
  belongs_to :engineering_project, optional: true

  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 5

  index do
    selectable_column

    column :id
    column :name
    column :type, sortable: :id do |obj|
      obj.model_name.human
    end
    column :engineering_project, sortable: :id do |obj|
      link_to obj.engineering_project.name, engineering_project_path(obj.engineering_project)
    end
    column :remark
    column :created_at
    column :updated_at

    actions do
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "工资表", "#"
    end
  end
end
