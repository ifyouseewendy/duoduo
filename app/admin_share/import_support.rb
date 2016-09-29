module ImportSupport
  def self.included(base)
    base.instance_eval do

      collection_action :import_demo do
        model = controller_name.classify.constantize

        filename = I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.xlsx'
        dir = Pathname("tmp/import_demo")
        dir.mkdir unless dir.exist?
        filepath = dir.join(filename)

        Axlsx::Package.new do |p|
          p.workbook.add_worksheet do |sheet|
            stat = model.ordered_columns(export: true).map{|col| model.human_attribute_name(col) }
            sheet.add_row stat
          end
          p.serialize(filepath.to_s)
        end

        send_file filepath
      end

      action_item :import_new, only: [:index] do
        if collection.model.name == 'GuardSalaryItem'
          link_to "导入#{collection.model_name.human}", send("import_new_guard_salary_table_#{collection.name.underscore.pluralize}_path")
        elsif collection.model.name == 'NonFullDaySalaryItem'
          link_to "导入#{collection.model_name.human}", send("import_new_non_full_day_salary_table_#{collection.name.underscore.pluralize}_path")
        elsif collection.model.name == 'SealItem'
          link_to "导入#{collection.model_name.human}", send("import_new_seal_table_#{collection.name.underscore.pluralize}_path")
        else
          link_to "导入#{collection.model_name.human}", send("import_new_#{collection.name.underscore.pluralize}_path")
        end
      end

      collection_action :import_new do
        render 'import_template'
      end

      collection_action :import_do, method: :post do
        file = params[collection.name.underscore].try(:[], :file)
        redirect_to :back, alert: '导入失败（未找到文件），请选择上传文件' and return \
          if file.nil?

        redirect_to :back, alert: '导入失败（错误的文件类型），请上传 xls(x) 类型的文件' and return \
          unless [
            "application/vnd.ms-excel",
            "application/octet-stream",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          ].include? file.content_type

        xls = Roo::Spreadsheet.open(file.path)
        sheet = xls.sheet(0)

        columns = collection.ordered_columns(export:true)

        foreign_keys = columns.select{|col| col.to_s =~ /_id$/ }

        boolean_and_enum_map = {
          '是' => true,
          '否' => false,
          '男' => 'male',
          '女' => 'female',
          '可用' => true,
          '不可用' => false,
        }.merge(Hash[NormalCorporation.admin_charge_types_option])

        stats = []
        (1..sheet.last_row).each do |row|
          data = sheet.row(row)
          next if data[0].blank?

          stat = data.each_with_index.reduce({}) do |ha, (val,col)|
            if col < columns.count
              key = columns[col]

              if String === val
                val.strip!
              elsif Numeric === val
                val = val.to_i if val.to_i == val
              end

              if row == 1 # first row is header
                ha[ key ] = val
              else
                if foreign_keys.include? key
                  klass = key.to_s.sub("_id", '').classify.constantize
                  # stat for foreign keys should be name, and foreign key class should validate on name field

                  if [NormalStaff, EngineeringStaff].include? klass
                    ha[ key ] = klass.where(identity_card: val).first.try(:id) \
                                  || klass.where(name: val).first.try(:id) \
                                  || klass.where(id: val).first.try(:id)
                  elsif [EngineeringCustomer].include? klass
                    if val.to_s.index('、')
                      nest_index, _ = val.to_s.split('、')
                    else
                      nest_index = val
                    end
                    ha[ key ] = klass.where(nest_index: val).first.try(:id)
                  else
                    ha[ key ] = klass.where(name: val).first.try(:id)
                  end
                else
                  ha[ key ] = boolean_and_enum_map[val] || val
                end
              end
            end

            ha
          end

          stats << stat
        end

        failed = []
        stats.each_with_index do |stat, idx|
          if idx == 0
            failed << stat.values
          else
            begin
              collection.create!( stat )
            rescue => e
              failed << (stat.values << e.message)
            end
          end
        end

        if failed.count > 1
          # generate new xls file

          filename = Pathname(file.original_filename).basename.to_s.split('.')[0]
          filepath = Pathname("tmp/#{filename}.#{Time.stamp}.xlsx")
          Axlsx::Package.new do |p|
            p.workbook.add_worksheet do |_sheet|
              failed.each{|stat| _sheet.add_row stat}
            end
            p.serialize(filepath.to_s)
          end
          send_file filepath
        else
          redirect_to send("#{collection.name.underscore.pluralize}_path"), notice: "成功导入 #{stats.count-1} 条记录"
        end

      end
    end
  end
end
