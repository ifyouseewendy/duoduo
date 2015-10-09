class NormalStaff < ActiveRecord::Base
  belongs_to :normal_corporation
  has_many :salary_items

  enum gender: [:male, :female]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end

    def genders_option
      genders.keys.map{|k| [I18n.t("activerecord.attributes.normal_staff.genders.#{k}"), k]}
    end

    def boolean_option
      [ ['是', true], ['否', false] ]
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: false)
      hash = fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash['gender_性别'] = genders_option
      hash['has_social_insurance_是否参社保'] = boolean_option
      hash['has_medical_insurance_是否参医保'] = boolean_option
      hash['in_service_在职'] = boolean_option
      hash['in_contract_有劳务关系'] = boolean_option
      hash['normal_corporation_id_所属单位'] = NormalCorporation.reference_option
      hash
    end
  end

  def gender_i18n
    I18n.t("activerecord.attributes.normal_staff.genders.#{gender}")
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

  def has_no_salary_item?
    salary_items.count == 0
  end

  def init_addition_fee
    {
      big_amount_personal: 96,
      medical_scan_addition: 10,
      salary_card_addition: 10
    }
  end

  def company_name
    normal_corporation.name rescue ''
  end
end
