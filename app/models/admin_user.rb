class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [
    :is_super_admin,
    :is_finance_admin,
    :is_finance_senior,
    :is_finance_junior,
    :is_business_admin,
  ]
  enum status: [:active, :locked]

  scope :finance, -> { where(role: finance_enum_ids) }
  scope :business, -> { where(role: business_enum_ids) }

  class << self

    def finance_enum_ids
      @_finance_enum_ids ||= \
        [:is_finance_admin, :is_finance_senior, :is_finance_junior].map{|f| self.roles[f]}
    end

    def business_enum_ids
      @_business_enum_ids ||= \
        [:is_business_admin].map{|f| self.roles[f]}
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

    def roles_option
      roles.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.roles.#{k}"), k]}
    end

  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def role_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.roles.#{role}")
  end

  def super_admin?
    is_super_admin?
  end

  def admin?
    is_super_admin? or is_finance_admin? or is_business_admin?
  end

  def finance?
    is_finance_admin? or is_finance_junior? or is_finance_senior?
  end

  def business?
    is_business_admin?
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
