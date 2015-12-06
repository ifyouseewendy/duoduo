class SubCompany < ActiveRecord::Base
  has_and_belongs_to_many :normal_corporations
  has_and_belongs_to_many :engineering_customers

  has_many :contract_files, dependent: :destroy

  has_many :labor_contracts
  has_many :normal_staffs

  mount_uploader :engi_contract_template, ContractTemplateUploader
  mount_uploader :engi_protocol_template, ContractTemplateUploader

  validates_uniqueness_of :name

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

  def remove_contract_template_at(id)
    templates = self.contract_templates
    templates.delete_at(id)
    self.contract_templates = templates

    self.save!
  end

  def add_contract_template(filename)
    add_file(filename, template: true)
  end

  def add_file(filename, override: false, template: false)
    field = template ? :contract_templates : :contracts
    if override
      self.send "#{field}=", [File.open(filename)]
    else
      self.send "#{field}=", self.send(field) + [File.open(filename)]
    end

    self.save!
  end

end
