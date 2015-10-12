module ImportSupport
  def self.included(base)
    base.instance_eval do

      collection_action :import_demo do
        model = controller_name.classify.constantize
        data = \
          CSV.generate encoding: 'GBK' do |csv|
            csv << [I18n.t("misc.import_demo.notice")]
            csv << model.ordered_columns(without_base_keys: true, without_foreign_keys: true).map{|col| model.human_attribute_name(col) }
          end
        send_data \
          data,
          :filename => I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.csv'
      end

      action_item :import_new, only: [:index] do
        link_to "导入#{collection.model_name.human}", send("import_new_#{collection.name.underscore.pluralize}_path")
      end

      collection_action :import_new do
        render 'import_template'
      end

      collection_action :import_do, method: :post do
        file = params[collection.name.underscore].try(:[], :file)
        redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
          if file.nil?

        redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
          unless ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type

        xls = Roo::Spreadsheet.open(file.path)
        sheet = xls.sheet(0)

        columns = collection.ordered_columns(without_base_keys: true, without_foreign_keys: true)

        stats = \
          (1..sheet.last_row).reduce([]) do |ar, i|
            stat = sheet.row(i).each_with_index.reduce({}) do |ha, (val,idx)|
              ha[ columns[idx] ] = val
              ha
            end

            ar << stat
          end

        failed = []
        stats.each do |stat|
          begin
            collection.create!( stat )
          rescue => e
            failed << (ha.values << e.message)
          end
        end

        if failed.count > 0
          # generate new xls file

          filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
          filepath = Pathname("tmp/#{filename}_#{Time.stamp}.xlsx")
          Axlsx::Package.new do |p|
            p.workbook.add_worksheet do |sheet|
              failed.each{|stat| sheet.add_row stat}
            end
            p.serialize(filepath.to_s)
          end
          send_file filepath
        else
          redirect_to send("#{collection.name.underscore.pluralize}_path"), notice: "成功导入 #{stats.count} 条记录"
        end

      end
    end
  end
end
