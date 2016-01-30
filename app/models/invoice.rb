class Invoice < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  # belongs_to :invoicable, polymorphic: true
  belongs_to :sub_company, required: true
  belongs_to :project, polymorphic: true

  enum category: [:normal, :vat_a, :vat_b]
  enum status: [:work, :red, :cancel, :archive]
  enum scope: [:business, :engineer]

  validates_presence_of :date, :code, :encoding, :status, :category, :scope, :payer

  before_save :revise_fields

  class << self
    def policy_class
      TellerPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def statuses_option(filter: false)
      if filter
        statuses.map{|k,v| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), v]}
      else
        statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
      end
    end

    def categories_option(filter: false)
      if filter
        categories.map{|k,v| [I18n.t("activerecord.attributes.#{self.name.underscore}.categories.#{k}"), v]}
      else
        categories.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.categories.#{k}"), k]}
      end
    end

    def scopes_option(filter: false)
      if filter
        scopes.map{|k,v| [I18n.t("activerecord.attributes.#{self.name.underscore}.scopes.#{k}"), v]}
      else
        scopes.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.scopes.#{k}"), k]}
      end
    end

    def export_xlsx(options: {})
      names = [self.model_name.human, self.invoicable.name, Time.stamp]
      filename = "#{names.join('_')}.xlsx"
      filepath = EXPORT_PATH.join filename

      st = SalaryTable.find(options[:salary_table_id])
      collection = st.invoices
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

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
        ordered_columns(without_foreign_keys: true)
      end
    end

    def batch_form_fields
      contacts = NormalCorporation.includes(:sub_company).select(:name, :sub_company_id).map{|nc| ["#{nc.sub_company.name} - #{nc.name}", nc.name]}
      contacts += EngineeringCustomer.select(:name, :nest_index).map{|ec| [ec.display_name, ec.display_name]}
      hash = {
        'status_状态' => statuses_option,
        'scope_用于' => scopes_option,
        'contact_联系人' =>  contacts
      }
      [:date, :payer, :management, :amount, :admin_amount, :income_date, :refund_date, :refund_person, :remark].each do |k|
        hash[ "#{k}_#{human_attribute_name(k)}" ] = :text
      end
      hash
    end
  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def status_tag
    case status
    when 'red'
      :red
    when 'archive'
      :no
    when 'cancel'
      :cancel
    else
      :yes
    end
  end

  def category_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.categories.#{category}")
  end

  def category_tag
    case category
    when 'vat_a'
      :orange
    when 'vat_b'
      :red
    else
      :ok
    end
  end

  def scope_i18n
    scp = self.scope || :nil
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.scopes.#{scp}")
  end

  def revise_fields
    if (changed & ['amount', 'admin_amount']).present?
      self.total_amount = [amount, admin_amount].map(&:to_f).sum.round(2)
    end

    if changes['status'].present? && changes['status'][-1] == 'cancel'
      [:scope, :contact, :payer, :amount, :admin_amount, :total_amount, :income_date, :refund_person, :refund_date].each do |key|
        self.send("#{key}=", nil)
      end
    end
  end

  # Form placeholder
  def invoice_setting_id
  end

  def batch_create
  end

  def batch_count
  end

  def batch_file
  end
end
