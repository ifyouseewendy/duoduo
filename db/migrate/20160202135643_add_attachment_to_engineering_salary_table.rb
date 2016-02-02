class AddAttachmentToEngineeringSalaryTable < ActiveRecord::Migration
  def change
    add_column :engineering_salary_tables, :attachment, :text
  end
end
