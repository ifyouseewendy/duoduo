class AuditionItem < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true

  enum status: [:init, :apply_audit, :already_audit, :history]

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end
end
