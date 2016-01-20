class EngineeringNormalWithTaxSalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.staff.try(:name)].compact.join(' - ') },
    }

  belongs_to :salary_table, \
    class_name: EngineeringNormalWithTaxSalaryTable,
    foreign_key: :engineering_salary_table_id,
    inverse_of: :salary_items,
    required: true

  belongs_to :staff, \
    class: EngineeringStaff, \
    foreign_key: :engineering_staff_id,
    required: true

  validates_uniqueness_of :staff, scope: :salary_table

  before_save :revise_fields
  after_save :validate_salary_table

  class << self
    def policy_class
      EngineeringSalaryItemPolicy
    end

    def create_by(table:, staff:, salary_deserve:)
      item = self.new(salary_table: table, staff: staff)

      item.salary_deserve     = salary_deserve

      date = table.start_date

      item.social_insurance = EngineeringCompanySocialInsuranceAmount.query_amount(date: date)
      item.medical_insurance = EngineeringCompanyMedicalInsuranceAmount.query_amount(date: date)

      item.save!
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        [:engineering_staff_id, :salary_deserve, :social_insurance, :medical_insurance, :remark]
      else
        names = column_names.map(&:to_sym)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(engineering_salary_table_id engineering_staff_id) if without_foreign_keys

        names
      end
    end

    def sum_fields
      [:salary_deserve, :social_insurance, :medical_insurance, :total_insurance, :total_amount, :tax, :salary_in_fact]
    end

    def batch_form_fields
      hash = {}
      fields = [:salary_deserve, :social_insurance, :medical_insurance, :tax]
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

    def export_xlsx(options: {})
      collection = self.all
      names = [self.model_name.human]

      if options[:selected].present?
        collection = collection.where(id: options[:selected])
      else
        collection = collection.ransack(options).result
      end

      salary_table = collection.first.salary_table
      names += [salary_table.project.name, salary_table.month_display]

      if options[:order].present?
        order = :asc
        order = :desc if options[:order].end_with?('desc')

        if options[:order].start_with?('engineering_staffs')
          collection = collection.includes(:staff).order("engineering_staffs.seal_index #{order}")
        else
          key = options[:order].split("_")[0..-2].join('_')
          collection = collection.order("#{key} #{order}")
        end
      end

      names << Time.stamp

      filename = "#{names.join('_')}.xlsx"
      filepath = EXPORT_PATH.join filename

      columns = columns_based_on(options: options) - [:remark, :created_at, :updated_at] + [:blank_sign]
      Axlsx::Package.new do |p|
        wb = p.workbook
        wrap_header_first = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          height: 25,
          b: true,
          sz: 18
        })
        wrap_header_second = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          height: 25,
          b: true,
          sz: 14
        })
        wrap_header_third = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          border: {style: :thin, color: '00'},
          height: 60,
          sz: 12
        })
        wrap_text = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          border: {style: :thin, color: '00'},
          height: 30,
          sz: 12
        })
        wrap_float_text = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          border: {style: :thin, color: '00'},
          height: 30,
          format_code: '0.00',
          sz: 12
        })

        sheet_name = salary_table.month_display
        wb.add_worksheet(name: sheet_name) do |sheet|
          # Headers
          sheet.add_row [ salary_table.project.try(:corporation).try(:name) ], \
            style: wrap_header_first
          sheet.add_row [ salary_table.month_display_zh + " 工资表" ], \
            style: wrap_header_second
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}, \
            style: wrap_header_third

          end_col = ('A'.ord + columns.count - 1).chr
          sheet.merge_cells("A1:#{end_col}1")
          sheet.merge_cells("A2:#{end_col}2")

          # Content
          # records = collection.includes(:staff).sort_by{|si| si.staff.seal_index.to_s}
          collection.each_with_index do |item,idx|
             stats = \
              columns.map do |col|
                if [:staff].include? col
                  item.send(col).name
                elsif [:id].include? col
                  idx+1
                else
                  item.send(col)
                end
              end
              sheet.add_row stats, style: ( [wrap_text, wrap_text]+[wrap_float_text]*7+[wrap_text] ), height: 30
          end

          # Sum row
          stats = columns.reduce([]) do |ar, col|
            if sum_fields.include?(col)
              ar << collection.sum(col)
            else
              ar << nil
            end
          end
          stats[0] = '合计'
          sheet.add_row stats, style: ( [wrap_text, wrap_text]+[wrap_float_text]*7 ), height: 30

          end_rol = 3 + collection.count + 1
          sheet.merge_cells("A#{end_rol}:B#{end_rol}")

          widths = Array.new(columns.count+1){10}
          sheet.column_widths *widths

          wb.add_defined_name("'#{sheet_name}'!$1:$3", :local_sheet_id => sheet.index, :name => '_xlnm.Print_Titles') 
        end
        p.serialize(filepath.to_s)
      end

      filepath
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        %i(id staff) \
          + (ordered_columns(without_foreign_keys: true) - %i(id))
      end
    end
  end

  def revise_fields
    if (changed & ['salary_deserve', 'social_insurance', 'medical_insurance', 'tax']).present?
      self.total_insurance  = self.social_insurance + self.medical_insurance
      self.total_amount     = self.salary_deserve + self.total_insurance
      self.tax              = IndividualIncomeTax.calculate(salary: self.total_amount) unless (changed & ['tax']).present?
      self.salary_in_fact   = self.total_amount - self.tax
    end
  end

  def validate_salary_table
    if (changed & ['total_amount']).present?
      self.salary_table.validate_amount
    end
  end

  # Export placeholder
  def blank_sign
  end
end
