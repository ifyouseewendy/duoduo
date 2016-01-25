class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [
    :is_super_admin,
    :is_finance_admin,
    # :is_finance_senior,
    # :is_finance_junior,
    :is_business_admin,
    :is_teller
  ]
  enum status: [:active, :locked]

  scope :super_admin, -> { where(role: 'is_super_admin') }
  scope :finance, -> { where(role: finance_enum_ids) }
  scope :business, -> { where(role: business_enum_ids) }

  class << self

    def finance_fields
      @_finance_fields ||= [:is_finance_admin]
    end

    def finance_enum_ids
      @_finance_enum_ids ||= finance_fields.map{|f| self.roles[f]}
    end

    def business_fields
      @_business_fields ||= [:is_business_admin]
    end

    def business_enum_ids
      @_business_enum_ids ||= business_fields.map{|f| self.roles[f]}
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

    def roles_option(user:)
      keys = \
        if user.is_super_admin?
          roles.keys
        elsif user.is_finance_admin?
          finance_fields
        elsif user.is_business_admin?
          business_fields
        else
          []
        end
      keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.roles.#{k}"), k]}
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
    is_super_admin?
  end

  def finance?
    is_finance_admin?
  end

  def business?
    is_business_admin?
  end

  def finance_admin?
    is_super_admin? or is_finance_admin?
  end

  def teller?
    is_teller?
  end

  # def finance_normal?
  #   is_finance_junior? or is_finance_senior?
  # end

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
