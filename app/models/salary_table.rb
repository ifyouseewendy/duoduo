class SalaryTable < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :normal_corporation
  has_many :salary_items, dependent: :destroy
  # has_many :invoices, dependent: :destroy, as: :invoicable

  mount_uploader :lai_table, Attachment
  mount_uploader :daka_table, Attachment

  enum status: [:active, :archive]

  validates_presence_of :start_date

  before_create :set_audition

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end

    def dates_as_filter
      self.select(:start_date).distinct.order(start_date: :desc).map{|st| [st.month, st.start_date.to_s] }
    end

    def statuses_option(filter: false)
      if filter
        statuses.map{|k,v| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), v]}
      else
        statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
      end
    end

    def batch_form_fields
      fields = [:remark]
      hash = {
        'status_状态' => [ ['活动', 'active'], ['存档', 'archive'] ],
      }
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end
  end

  def corporation
    normal_corporation
  end

  def export_xlsx(view: nil, options: {})
    staff_view = options['normal_staff_id_eq'].present?
    if staff_view
      collection = SalaryItem.ransack(options).result
      staff_name = collection.first.staff_name
      sheet_name = staff_name
      filename = "#{staff_name}_#{Time.stamp}.xlsx"
    else
      collection = salary_items.order(nest_index: :asc)
      sheet_name = name
      filename = filename_by(view: view)
    end

    filepath = EXPORT_PATH.join filename

    collection = collection.where(id: options[:selected]) if options[:selected].present?

    columns = present_fields(collection: collection, view: view, custom: options[:custom])

    data_types = columns.reduce([]) do |ar, col|
      if col == :staff_account
        ar << :string
      else
        ar << nil
      end
    end

    Axlsx::Package.new do |p|
      wb = p.workbook
      wrap_header_first = wb.styles.add_style({
        font_name: "新宋体",
        alignment: {horizontal: :center, vertical: :center, wrap_text: true},
        b: true,
        sz: 18
      })
      wrap_header_second = wb.styles.add_style({
        font_name: "新宋体",
        alignment: {horizontal: :center, vertical: :center, wrap_text: true},
        height: 30,
        b: true,
        sz: 12
      })
      wrap_header_third = wb.styles.add_style({
        font_name: "新宋体",
        alignment: {horizontal: :center, vertical: :center, wrap_text: true},
        border: {style: :thin, color: '00'},
        height: 60,
        sz: 10
      })
      wrap_text = wb.styles.add_style({
        font_name: "新宋体",
        alignment: {horizontal: :center, vertical: :center, wrap_text: true},
        border: {style: :thin, color: '00'},
        height: 30,
        sz: 10
      })
      wrap_float_text = wb.styles.add_style({
        font_name: "新宋体",
        alignment: {horizontal: :right, vertical: :center, wrap_text: true},
        border: {style: :thin, color: '00'},
        height: 30,
        format_code: '0.00',
        sz: 10
      })
      margins = {left: 0.1, right: 0.1, top: 0.1, bottom: 0.1}
      setup = {fit_to_width: 1, orientation: :landscape}

      wb.add_worksheet(name: sheet_name, page_margins: margins, page_setup: setup) do |sheet|
        # Fit to page printing
        # sheet.page_setup.fit_to :width => 1

        # Headers
        if staff_view
          sheet.add_row columns.map{|col| SalaryItem.human_attribute_name(col)}, \
            height: 60, b:true, style: wrap_header_third
        else
          sheet.add_row [ corporation.full_name || corporation.name ], \
            height: 60, b:true, sz: 16, style: wrap_header_first
          sheet.add_row [ start_date.to_s ], \
            height: 30, b:true, style: wrap_header_second
          sheet.add_row columns.map{|col| SalaryItem.human_attribute_name(col)}, \
            height: 60, b:true, style: wrap_header_third

          end_col = ('A'.ord + columns.count - 1).chr
          sheet.merge_cells("A1:#{end_col}1")
          sheet.merge_cells("A2:#{end_col}2")
        end

        # Content
        collection.each do |item|
          data = columns.map do |col|
            item.send(col).to_s
          end
          sheet.add_row data, style: ([wrap_text]*3 + [wrap_float_text]*(columns.count-3)), height: 30, types: data_types
        end

        # Sum row
        stats = columns.reduce([]) do |ar, col|
          if SalaryItem.sum_fields.include?(col)
            ar << collection.sum(col).to_f.round(2)
          else
            ar << nil
          end
        end
        stats[0] = '合计'
        sheet.add_row stats, style: ([wrap_text]*1 + [wrap_float_text]*(columns.count-1)), height: 30

        end_rol = 3 + collection.count + 1
        sheet.merge_cells("A#{end_rol}:C#{end_rol}")

        # Footer
        sheet.add_row []
        sheet.add_row [ ['经理：', '财务：', '部门经理:', '审核：', '复核：', '制表：'].join('                    ') ]

        # Set First column width
        # widths = [3, 20, 8] + Array.new(columns.count+1-3){8}
        sheet.column_widths 5

        wb.add_defined_name("'#{sheet_name}'!$1:$3", :local_sheet_id => sheet.index, :name => '_xlnm.Print_Titles') 
      end
      p.serialize(filepath.to_s)
    end

    filepath
  end

  def filename_by(view: nil)
    filename = \
      case view.to_s
      when "proof"    then "凭证工资表（帐用）"
      when "card"     then "打卡表"
      when "custom"   then "自定义工资表"
      when "whole"    then "全部字段工资表"
      else "基础工资表"
      end
    "#{corporation.name}_#{name}_#{filename}_#{Time.stamp}.xlsx"
  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def month
    start_date.strftime("%Y年%m月")
  end

  def available_nest_index
    ( salary_items.reorder(nest_index: :desc).first.try(:nest_index) || 0 ) + 1
  end

  def present_fields(collection:, view: , custom: )
    fields = SalaryItem.columns_based_on(view: view, custom: custom)
    fields.select do |key|
      collection.map{|obj| obj.send(key)}.any? do |val|
        if Numeric === val
          val.nonzero?
        else
          val.present?
        end
      end
    end
  end

  def display_name
    name
  end

  AUDITION_STAGE = [:make_table, :audit_first, :audit_second, :audit_finance]
  def set_audition
    AUDITION_STAGE.each{|k| self.audition[k] = nil}
  end

  def audition_display
    {
      make_table: '制表',
      audit_first: '复核',
      audit_second: '审核',
      audit_finance: '财务',
    }
  end
end
