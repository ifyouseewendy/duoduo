class SalaryTable < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :normal_corporation
  has_many :salary_items, dependent: :destroy
  has_many :invoices, dependent: :destroy, as: :invoicable

  mount_uploader :lai_table, Attachment
  mount_uploader :daka_table, Attachment

  enum status: [:active, :archive]

  validates_presence_of :start_date

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end

    def dates_as_filter
      self.select(:start_date).distinct.order(start_date: :desc).map{|st| [st.month, st.start_date.to_s] }
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
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
    filename = filename_by(view: view)
    filepath = EXPORT_PATH.join filename

    collection = salary_items.order(nest_index: :asc)
    collection = collection.where(id: options[:selected]) if options[:selected].present?

    columns = present_fields(view: view, custom: options[:custom])

    Axlsx::Package.new do |p|
      wb = p.workbook
      wrap_text = wb.styles.add_style({
        alignment: {horizontal: :center, vertical: :center, wrap_text: true},
        border: {style: :thin, color: '00'}
      })

      wb.add_worksheet(name: name) do |sheet|
        # Headers
        sheet.add_row [ corporation.full_name || corporation.name ], \
          height: 60, b:true, sz: 16, style: wrap_text
        sheet.add_row [ start_date.to_s ], \
          height: 30, b:true, style: wrap_text
        sheet.add_row columns.map{|col| SalaryItem.human_attribute_name(col)}, \
          height: 60, b:true, style: wrap_text

        end_col = ('A'.ord + columns.count - 1).chr
        sheet.merge_cells("A1:#{end_col}1")
        sheet.merge_cells("A2:#{end_col}2")

        # Content
        collection.each do |item|
          data = columns.map do |col|
            if :staff_account == col
              "'#{item.send(col).to_s}"
            else
              item.send(col).to_s
            end
          end
          sheet.add_row data, style: wrap_text
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
        sheet.add_row stats, style: wrap_text

        end_rol = 3 + collection.count + 1
        sheet.merge_cells("A#{end_rol}:C#{end_rol}")

        # Footer
        sheet.add_row []
        sheet.add_row [ ['经理：', '财务：', '部门经理:', '审核：', '复核：', '制表：'].join('                    ') ]

        # Set First column width
        # widths = [3, 20, 8] + Array.new(columns.count+1-3){8}
        sheet.column_widths 5
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
    ( salary_items.order(nest_index: :desc).first.try(:nest_index) || 0 ) + 1
  end

  def present_fields(view: , custom: )
    fields = SalaryItem.columns_based_on(view: view, custom: custom)
    fields.select do |key|
      salary_items.map{|obj| obj.send(key)}.any? do |val|
        if Numeric === val
          val.nonzero?
        else
          val.present?
        end
      end
    end
  end

end
