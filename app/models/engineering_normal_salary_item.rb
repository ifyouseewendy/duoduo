class EngineeringNormalSalaryItem < ActiveRecord::Base
  belongs_to :salary_table, \
    class_name: EngineeringNormalSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items

  belongs_to :engineering_staff

  class << self
    def create_by(table:, staff:, salary_in_fact:)
      item = self.new(salary_table: table, engineering_staff: staff)
      item.salary_in_fact =  salary_in_fact
      item.social_insurance = 407
      item.medical_insurance = 249
      item.total_insurance = 407 + 249
      item.salary_deserve = salary_in_fact - 407 - 249

      item.save!
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_salary_table_id engineering_staff_id) if without_foreign_keys

      names
    end

    def export_xlsx(options: {})
      collection = self.all
      names = [self.model_name.human]

      if options[:selected].present?
        collection = collection.where(id: options[:selected])
      elsif options[:salary_table_id].present?
        salary_table = EngineeringSalaryTable.find(options[:salary_table_id])
        collection = salary_table.salary_items
        names += [salary_table.engineering_project.name, salary_table.name]
      end
      names << Time.stamp

      filename = "#{names.join('_')}.xlsx"
      filepath = EXPORT_PATH.join filename

      columns = columns_based_on(options: options)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                if [:engineering_staff].include? col
                  item.send(col).name
                else
                  item.send(col)
                end
              end
              sheet.add_row stats
          end
        end
        p.serialize(filepath.to_s)
      end

      filepath
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        %i(id engineering_staff) \
          + (ordered_columns(without_foreign_keys: true) - %i(id))
      end
    end
  end
end
