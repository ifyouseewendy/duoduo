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

  class << self

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def super_admin?
    is_super_admin?
  end

  def admin?
    is_super_admin?
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
