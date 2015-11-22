class EngineeringNormalWithTaxSalaryItem < ActiveRecord::Base
  belongs_to :salary_table, \
    class_name: EngineeringNormalWithTaxSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items

  belongs_to :engineering_staff

  before_save :revise_fields

  class << self
    def policy_class
      EngineeringPolicy
    end

    def create_by(table:, staff:, salary_deserve:)
      item = self.new(salary_table: table, engineering_staff: staff)

      item.salary_deserve     = salary_deserve

      project = item.salary_table.engineering_project

      dates = table.name.split('~').map(&:strip)
      date = dates.count == 2 ? dates[0] : project.project_start_date

      item.social_insurance = EngineeringCompanySocialInsuranceAmount.query_amount(date: date)
      item.medical_insurance = EngineeringCompanyMedicalInsuranceAmount.query_amount(date: date)

      item.save!
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_salary_table_id engineering_staff_id) if without_foreign_keys

      names
    end

    def batch_form_fields
      hash = {}
      fields = [:salary_deserve, :social_insurance, :medical_insurance]
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
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
        p.workbook.add_worksheet(name: name[0,31]) do |sheet|
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

  def revise_fields
    if (changed && [:salary_deserve, :social_insurance, :medical_insurance]).present?
      self.total_insurance  = self.social_insurance + self.medical_insurance
      self.total_amount     = self.salary_deserve + self.total_insurance
      self.tax              = IndividualIncomeTax.calculate(salary: self.total_amount) unless (changed && [:tax]).present?
      self.salary_in_fact   = self.total_amount - self.tax
    end
  end
end
