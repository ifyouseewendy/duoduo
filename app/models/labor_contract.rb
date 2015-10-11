class LaborContract < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :normal_corporation
  belongs_to :normal_staff

  # 合同、退休返聘、临时、非全日制、无协议
  enum contract_type: [:normal_contract, :retire_contract, :temp_contract, :none_full_day_contract, :none_contract]

  scope :active, -> { where(in_contract: true) }
  scope :active_order, -> { order(in_contract: :desc) }

  after_update :check_active_status
  after_update :check_relationship

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id sub_company_id normal_staff_id) if without_foreign_keys

      names
    end

    def contract_types_option
      contract_types.keys.map{|k| [I18n.t("activerecord.attributes.labor_contract.contract_types.#{k}"), k]}
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

  end

  def name
    "#{normal_corporation.name} - #{normal_staff.name}"
  end

  def contract_type_i18n
    I18n.t("activerecord.attributes.labor_contract.contract_types.#{contract_type}")
  end

  def insurance_fund
    personal_rate = InsuranceFundRate.personal
    company_rate = InsuranceFundRate.company

    stats = {
      pension_personal: 0,
      unemployment_personal: 0,
      medical_personal: 0,
      pension_company: 0,
      unemployment_company: 0,
      injury_company: 0,
      birth_company: 0,
      medical_company: 0
    }

    if has_social_insurance
      stats[:pension_personal]      = social_insurance_base * personal_rate.pension
      stats[:unemployment_personal] = social_insurance_base * personal_rate.unemployment

      stats[:pension_company]       = social_insurance_base * company_rate.pension
      stats[:unemployment_company]  = social_insurance_base * company_rate.unemployment
      stats[:injury_company]        = social_insurance_base * company_rate.injury
      stats[:birth_company]         = social_insurance_base * company_rate.birth
    end

    if has_medical_insurance
      stats[:medical_personal]      = medical_insurance_base * personal_rate.medical
      stats[:medical_company]       = medical_insurance_base * company_rate.medical
    end

    stats[:house_accumulation_personal] = personal_rate.house_accumulation
    stats[:house_accumulation_company] = company_rate.house_accumulation

    stats
  end

  def activate!
    update_attribute(:in_contract, true)
  end

  def inactivate!
    update_attribute(:in_contract, false)
  end

  private

    def check_active_status
      if in_contract_change == [false, true]
        other_active_contracts = normal_staff.labor_contracts.where.not(id: self.id).active
        if other_active_contracts.count > 0
          # callbacks skipped
          other_active_contracts.each{|lc| lc.update_column(:in_contract, false)}
        end
      end
    end

    def check_relationship
      if changed.include? 'normal_corporation_id'
        normal_staff.update_attribute(:normal_corporation_id, self.normal_corporation_id)
      end

      if changed.include? 'sub_company_id'
        normal_staff.update_attribute(:sub_company_id, self.sub_company_id)
      end
    end

end
