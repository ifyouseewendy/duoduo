class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:in_administration, :in_business, :in_finance]
  enum status: [:active, :locked]

  def admin?
    in_administration?
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
