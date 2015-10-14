class NormalCorporation < ActiveRecord::Base
  has_and_belongs_to_many :sub_companies
  has_many :contract_files, through: :sub_companies
  has_many :normal_staffs
  has_many :salary_tables
  has_many :salary_items, through: :salary_tables
  has_many :labor_contracts

  validates_uniqueness_of :name

  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  enum admin_charge_type: [:by_rate_on_salary, :by_rate_on_salary_and_company, :by_count]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def admin_charge_types_option
      admin_charge_types.keys.map{|k| [I18n.t("activerecord.attributes.normal_corporation.admin_charge_types.#{k}"), k]}
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)
      hash = fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash['admin_charge_type_管理费收取方式'] = NormalCorporation.admin_charge_types_option
      hash
    end

    def reference_option
      order(id: :asc).pluck(:name, :id)
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.normal_corporation")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                if col == :admin_charge_type
                  item.send(:admin_charge_type_i18n)
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
        %i(id name) \
          + %i(sub_companies_display stuff_count stuff_has_insurance_count) \
          + (NormalCorporation.ordered_columns(without_foreign_keys: true) - %i(id name) )
      end
    end
  end

  def sub_companies_display
    sub_company_names.join(' ')
  end

  def sub_company_names
    sub_companies.map(&:name)
  end

  def admin_charge_type_i18n
    I18n.t("activerecord.attributes.normal_corporation.admin_charge_types.#{admin_charge_type}")
  end

  def by_rate?
    by_rate_on_salary? || by_rate_on_salary_and_company?
  end

  def stuff_count
    normal_staffs.count
  end

  def stuff_has_insurance_count
    normal_staffs.includes(:labor_contracts).select(&:has_insurance?).count
  end
end
