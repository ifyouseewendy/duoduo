ActiveAdmin.register SealItem do
  belongs_to :seal_table

  include ImportSupport

  index download_links: false do
    selectable_column

    column :nest_index
    column :name
    column :remark
    column :updated_at
    column :created_at

    actions
  end

  preserve_default_filters!
  remove_filter :seal_table

  permit_params { resource_class.column_names }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :nest_index, as: :number
      f.input :name, as: :string
      f.input :remark, as: :text
    end

    f.actions
  end

  collection_action :import_demo do
    model = controller_name.classify.constantize

    filename = I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.xlsx'
    dir = Pathname("tmp/import_demo")
    dir.mkdir unless dir.exist?
    filepath = dir.join(filename)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet do |sheet|
        stat = [:name].map{|col| model.human_attribute_name(col) }
        sheet.add_row stat
      end
      p.serialize(filepath.to_s)
    end

    send_file filepath
  end

  collection_action :import_do, method: :post do
    file = params[collection.name.underscore].try(:[], :file)
    redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
      if file.nil?

    redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
      unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

    xls = Roo::Spreadsheet.open(file.path)
    sheet = xls.sheet(0)

    table = SealTable.where(id: request.path.split('/')[2]).first
    redirect_to :back, alert: '错误的请求，未找到 SealTable: #{request.path}' and return \
      if table.blank?

    start_index = index = table.latest_item_index
    sheet.to_a[1..-1].each do |row|
      name = row[0]
      next if name.blank?

      name = name.strip.delete(' ')
      next if table.seal_items.where(name: name).first.present?

      table.seal_items.create!(nest_index: index, name: name)
      index += 1
    end

    count = index - start_index
    redirect_to seal_table_seal_items_path(table), notice: "成功导入 #{count} 条记录"
  end

end
