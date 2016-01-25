class InvoiceSetting < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human].compact.join(' - ') },
    }

  enum category: [:normal, :vat_a, :vat_b]
  enum status: [:active, :archive]

  validates_presence_of :category, :code, :start_encoding, :available_count, :status
  validate :uniq_encoding

  scope :available, ->(category){ self.send(category).active.order(created_at: :asc) }

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

  def end_encoding
    se = start_encoding.clone
    (available_count-1).times{ se.succ! }
    se
  end

  def range_integer
    Integer(start_encoding, 10)..Integer(end_encoding, 10)
  end

  def others
    self.class.send(category).where(code: code).where.not(id: self.id) rescue []
  end

  def uniq_encoding
    others.each do |is|
      # Range#overlaps use #cover, which use <=> comparison,
      # which is not accurate for string format numbers, like '99999' > '100000' # => true
      if self.range_integer.overlaps?(is.range_integer)
        errors.add(:start_encoding, "编码范围与已存在发票（类型<#{category_i18n}>代码<#{code}>）的编码范围有重叠")
      end
    end
  end

  def next_encoding
    last_encoding.nil? ? start_encoding : last_encoding.succ
  end

  def increment_used!
    self.class.transaction do
      self.last_encoding = next_encoding
      self.used_count += 1

      if available_count == used_count
        self.status = 'archive'
      end

      self.save!
    end
  end
end
