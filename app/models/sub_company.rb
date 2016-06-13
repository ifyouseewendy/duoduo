class SubCompany < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  # Business
  has_many :normal_corporations
  mount_uploader :busi_contract_template, ContractTemplateUploader
  has_many :normal_staffs

  # Engineer
  has_many :projects, class: EngineeringProject
  has_many :big_contracts
  mount_uploader :engi_contract_template, ContractTemplateUploader
  mount_uploader :engi_protocol_template, ContractTemplateUploader

  has_many :invoice_settings
  has_many :invoices

  # Validation
  validates_uniqueness_of :name

  # Scope
  scope :query_name, ->(name){ where("name LIKE '%#{name}%'") }
  scope :hr, ->{ where(has_engineering_relation: true) }

  class << self
    def policy_class
      SubCompanyPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def hr_options
      hr.select(:id,:name).map{|sc| [sc.name, sc.id]}
    end
  end

  def customers
    ids = projects.pluck(:engineering_customer_id)
    EngineeringCustomer.where(id: ids)
  end

  def corporations
    ids = projects.pluck(:engineering_corp_id)
    EngineeringCorp.where(id: ids)
  end

  def last_invoice_setting
    is = invoice_settings.last
    if is.present?
      { category: is.category, code: is.code, encoding: is.next_encoding }
    else
      { category: 'normal', code: '', encoding: '' }
    end
  end
end
