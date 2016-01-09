class SubCompany < ActiveRecord::Base
  # Business
  has_many :normal_corporations
  has_many :labor_contracts
  has_many :normal_staffs
  has_many :contract_templates, dependent: :destroy

  # Engineer
  has_many :projects, class: EngineeringProject
  has_many :big_contracts
  mount_uploader :engi_contract_template, ContractTemplateUploader
  mount_uploader :engi_protocol_template, ContractTemplateUploader

  # Validation
  validates_uniqueness_of :name

  # Scope
  scope :query_name, ->(name){ where("name LIKE '%#{name}%'") }
  scope :hr, ->{ where(has_engineering_relation: true) }

  class << self
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

  def add_contract_template(filename)
    self.contract_templates.create(contract: File.open(filename))
  end

  def add_file(filename, template: false)
    if template
      self.contract_templates.create!(contract: File.open(filename))
    else
      self.contract_files.create!(contract: File.open(filename))
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

end
