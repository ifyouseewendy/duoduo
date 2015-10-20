class GuardSalaryTable < ActiveRecord::Base
  belongs_to :normal_corporation
  has_many :guard_salary_items, dependent: :destroy
  has_many :invoices, dependent: :destroy

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

  def export_xlsx(options: {})
    filename = "#{I18n.t("activerecord.models.guard_salary_table")}_#{Time.stamp}.xlsx"
    filepath = EXPORT_PATH.join filename

    collection = guard_salary_items
    collection = collection.where(id: options[:selected]) if options[:selected].present?

    columns = GuardSalaryItem.columns_based_on(options: options)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: name) do |sheet|
        sheet.add_row columns.map{|col| GuardSalaryItem.human_attribute_name(col)}

        collection.each do |item|
          sheet.add_row columns.map{|col| item.send(col)}
        end
      end
      p.serialize(filepath.to_s)
    end

    filepath
  end
end
