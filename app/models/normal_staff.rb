class NormalStaff < ActiveRecord::Base
  belongs_to :normal_corporation
  belongs_to :sub_company
  has_many :salary_items, dependent: :destroy
  has_many :labor_contracts, dependent: :destroy

  validates_uniqueness_of :identity_card

  enum gender: [:male, :female]

  after_update :check_contracts_status

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id sub_company_id) if without_foreign_keys

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

  def labor_contract
    labor_contracts.active.first
  end

  def insurance_fund
    labor_contract.try(:insurance_fund) || {}
  end

  def has_insurance?
    labor_contract.try(:has_insurance?)
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


  private

    def check_contracts_status
      if in_service_change == [true, false]
        labor_contracts.active.each(&:inactivate!)
      end
    end
end
