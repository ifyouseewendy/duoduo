class EngineeringCorp < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, _model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(_controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') }
    }

  has_many :projects, class: EngineeringProject
  has_many :big_contracts, -> { order(enable: :desc) }, dependent: :destroy

  class << self
    def policy_class
      EngineeringCorpPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym) + %i[contract_start_date contract_end_date]

      names -= %i[id created_at updated_at] if without_base_keys
      names -= %i[] if without_foreign_keys

      names
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.#{name.underscore}")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = all
      collection = if options[:selected].present?
                     collection.where(id: options[:selected])
                   else
                     collection.ransack(options).result
                   end

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map { |col| human_attribute_name(col) }

          collection.each do |item|
            stats = \
              columns.map do |col|
                item.send(col)
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
        ordered_columns(without_base_keys: true, without_foreign_keys: true)
      end
    end

    def as_option
      self.select(:id, :name, :created_at).order('created_at DESC').map do |ec|
        display_name = "#{ec.name} - #{ec.created_at.to_date}"
        [display_name, ec.id]
      end
    end
  end

  def customers
    ids = projects.pluck(:engineering_customer_id)
    EngineeringCustomer.where(id: ids)
  end

  def sub_companies
    ids = projects.pluck(:sub_company_id)
    SubCompany.where(id: ids)
  end

  def contract_start_date
    big_contracts.enable.map(&:start_date).min
  end

  def contract_end_date
    big_contracts.enable.map(&:end_date).max
  end

  def due?
    return false if contract_end_date.nil?

    Date.today + 1.month >= contract_end_date
  end

  ransacker :sub_company, formatter: lambda { |qid|
    sub_company = SubCompany.find(qid)
    sub_company.projects.pluck(:engineering_corp_id).compact.uniq
  } do |parent|
    parent.table[:id]
  end
end
