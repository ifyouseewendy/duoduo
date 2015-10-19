ActiveAdmin.register Invoice do
  belongs_to :salary_table

  # Collection actions
  collection_action :export_xlsx do
    options = {}
    options[:selected] = params[:selected].split('-') if params[:selected].present?
    options[:columns] = params[:columns].split('-') if params[:columns].present?
    options[:salary_table_id] = params[:salary_table_id].to_i

    file = Invoice.export_xlsx(options: options)
    send_file file, filename: file.basename
  end
end
