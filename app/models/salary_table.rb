class SalaryTable < ActiveRecord::Base
  belongs_to :normal_corporation
  has_many :salary_items, dependent: :destroy

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end
  end

  def corporation
    normal_corporation
  end

  def export_xlsx(view: nil, options: {})
    filename = filename_by(view: view)
    filepath = SALARY_TABLE_PATH.join filename

    columns = SalaryItem.columns_based_on(view: view)

    collectoin = salary_items
    collectoin = collectoin.where(id: options[:selected]) if options[:selected].present?

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: name) do |sheet|
        sheet.add_row columns.map{|col| SalaryItem.human_attribute_name(col)}

        collectoin.each do |item|
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
      when "archive"  then "存档工资表"
      when "proof"    then "凭证工资表"
      when "card"     then "打卡表"
      else "原始工资表"
      end
    "#{corporation.name}_#{name}_#{filename}.xlsx"
  end
end
