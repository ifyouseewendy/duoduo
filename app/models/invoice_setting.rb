class InvoiceSetting < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human].compact.join(' - ') },
    }

  enum category: [:normal, :vat_a, :vat_b]
  enum status: [:active, :archive]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

    def categories_option
      categories.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.categories.#{k}"), k]}
    end
  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def status_tag
    case status
    when 'active'
      :yes
    else
      :no
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
end
