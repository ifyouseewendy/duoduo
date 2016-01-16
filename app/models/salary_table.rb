class SalaryTable < ActiveRecord::Base
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

  end

  def corporation
    normal_corporation
  end

  def export_xlsx(view: nil, options: {})
    filename = filename_by(view: view)
    filepath = EXPORT_PATH.join filename

    collection = salary_items
    collection = collection.where(id: options[:selected]) if options[:selected].present?

    columns = SalaryItem.columns_based_on(view: view, options: options)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: name) do |sheet|
        sheet.add_row columns.map{|col| SalaryItem.human_attribute_name(col)}

        collection.each do |item|
          sheet.add_row columns.map{|col| item.send(col)}
        end
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

end
