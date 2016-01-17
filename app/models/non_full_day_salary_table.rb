class NonFullDaySalaryTable < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :normal_corporation
  has_many :non_full_day_salary_items, dependent: :destroy
  has_many :invoices, dependent: :destroy, as: :invoicable

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
    filename = "#{I18n.t("activerecord.models.non_full_day_salary_table")}_#{Time.stamp}.xlsx"
    filepath = EXPORT_PATH.join filename

    collection = non_full_day_salary_items
    collection = collection.where(id: options[:selected]) if options[:selected].present?

    columns = NonFullDaySalaryItem.columns_based_on(options: options)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: name) do |sheet|
        sheet.add_row columns.map{|col| NonFullDaySalaryItem.human_attribute_name(col)}

        collection.each do |item|
          sheet.add_row columns.map{|col| item.send(col)}
        end
      end
      p.serialize(filepath.to_s)
    end

    filepath
  end
end
