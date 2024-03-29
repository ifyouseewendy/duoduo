class NormalStaff < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :normal_corporation
  belongs_to :sub_company
  has_many :labor_contracts, dependent: :destroy

  has_many :salary_items, dependent: :destroy
  has_many :guard_salary_items, dependent: :destroy
  has_many :non_full_day_salary_items, dependent: :destroy

  validates_uniqueness_of :identity_card

  scope :in_service, -> { where(in_service: true) }
  scope :not_in_service, -> { where.not(in_service: true) }
  scope :in_contract, ->{ where(in_contract: true) }
  scope :not_in_contract, ->{ where.not(in_contract: true) }
  scope :zheqi, -> { where(name: "喆琦") }

  enum gender: [:male, :female]

  before_save :set_birth
  after_save :check_contracts_status

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        [
          :id,
          :name,
          :identity_card,
          :sub_company_id,
          :normal_corporation_id,
          :nest_index,
          :in_contract,
          :account,
          :account_bank,
          :birth,
          :age,
          :gender,
          :nation,
          :grade,
          :address,
          :telephone,
          :social_insurance_start_date,
          :remark
        ]
      else
        names = column_names.map(&:to_sym)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(normal_corporation_id sub_company_id) if without_foreign_keys

        names
      end
    end

    def genders_option(filter: false)
      if filter
        genders.map{|k,v| [I18n.t("activerecord.attributes.normal_staff.genders.#{k}"), v]}
      else
        genders.keys.map{|k| [I18n.t("activerecord.attributes.normal_staff.genders.#{k}"), k]}
      end
    end

    def boolean_option
      [ ['是', true], ['否', false] ]
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = [
        :account_bank,
        :nation,
        :grade,
        :remark
      ]
      hash = fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash['gender_性别'] = genders_option
      # hash['has_social_insurance_是否参社保'] = boolean_option
      # hash['has_medical_insurance_是否参医保'] = boolean_option
      # # hash['in_service_在职'] = boolean_option
      # hash['in_contract_有劳务关系'] = boolean_option
      # hash['normal_corporation_id_所属单位'] = NormalCorporation.reference_option
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.normal_staff")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      if options[:selected].present?
        collection = collection.where(id: options[:selected])
      else
        collection = collection.ransack(options).result
      end

      if options[:order].present?
        order = :asc
        order = :desc if options[:order].end_with?('desc')
        key = options[:order].split("_")[0..-2].join('_')
        collection = collection.order("#{key} #{order}")
      end

      columns = columns_based_on(options: options)

      data_types = columns.map do |col|
        if [:identity_card, :account].include?(col)
          :string
        else
          nil
        end
      end

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                if col == :sub_company_id
                  item.sub_company.try(:name)
                elsif col == :normal_corporation_id
                  item.normal_corporation.try(:name)
                elsif col == :in_contract
                  item.in_contract ? "有" : '无'
                elsif col == :gender
                  item.gender_i18n
                else
                  item.send(col)
                end
              end
              sheet.add_row stats, types: data_types
          end
        end
        p.serialize(filepath.to_s)
      end

      filepath
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        ordered_columns(export: true)
      end
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

  def set_birth
    if changed.include? 'identity_card'
      self.birth = Date.parse(self.identity_card[6,8]) rescue nil
      self.birth = nil if self.birth.try(:year).to_i < 1910
    end
  end

  def age
    return '' if birth.blank?

    num = Date.today.year - birth.year
    (birth + num.years >= Date.today) ? num-1 : num
  end

  private

    def check_contracts_status
      # if in_service_change == [true, false]
      #   labor_contracts.active.each(&:inactivate!)
      # end
    end
end
