class LaborContract < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.normal_staff.try(:name)].compact.join(' - ') },
    }

  belongs_to :normal_corporation
  belongs_to :normal_staff

  # 合同、退休返聘、临时、非全日制、无协议
  enum contract_type: [:normal_contract, :retire_contract, :temp_contract, :none_full_day_contract, :none_contract]

  scope :active, -> { where(in_contract: true) }
  scope :archive, -> { where.not(in_contract: true) }
  scope :active_order, -> { order(in_contract: :desc) }

  after_save :check_active_status
  after_save :check_relationship
  after_save :check_staff_in_contract
  after_save :set_nest_index

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        [
          :id,
          :normal_staff_id,
          :sub_company_id,
          :normal_corporation_id,
          :nest_index,
          :remark,
          :in_contract,
          :contract_type,
          :contract_start_date,
          :contract_end_date,
          :arrive_current_company_at,
          :has_social_insurance,
          :has_medical_insurance,
          :has_accident_insurance,
          :current_social_insurance_start_date,
          :current_medical_insurance_start_date,
          :social_insurance_base,
          :medical_insurance_base,
          :house_accumulation_base,
          :social_insurance_serial,
          :medical_insurance_serial,
          :medical_insurance_card,
          :backup_date,
          :backup_place,
          :work_place,
          :work_type,
          :release_date,
          :social_insurance_release_date,
          :medical_insurance_release_date,
        ]
      else
        names = column_names.map(&:to_sym)

        # Fields added by later migration
        polyfill = [:has_accident_insurance]
        names -= polyfill
        idx = names.index(:has_medical_insurance) + 1
        names.insert(idx, *polyfill)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(normal_corporation_id sub_company_id normal_staff_id) if without_foreign_keys

        names
      end
    end

    def contract_types_option(filter: false)
      if filter
        contract_types.map{|k,v| [I18n.t("activerecord.attributes.labor_contract.contract_types.#{k}"), v]}
      else
        contract_types.keys.map{|k| [I18n.t("activerecord.attributes.labor_contract.contract_types.#{k}"), k]}
      end
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      hash = {
        'in_contract_状态' => [ ['活动', true], ['解除', false] ],
        'has_social_insurance_社保' => [ ['有', true], ['无', false] ],
        'social_insurance_base_社保基数' => :text,
        'has_medical_insurance_医保' => [ ['有', true], ['无', false] ],
        'medical_insurance_base_医保基数' => :text,
        'has_accident_insurance_意外险' => [ ['有', true], ['无', false] ],
        'house_accumulation_base_住房公积金基数' => :text,
      }

      fields = [
        :backup_date,
        :backup_place,
        :work_place,
        :work_type,
        :release_date,
        :social_insurance_release_date,
        :medical_insurance_release_date,
        :remark,
      ]
      fields.each{|fi| hash[ "#{fi}_#{human_attribute_name(fi)}" ] = :text }

      hash
    end

    def batch_copy_fields
      corps = NormalCorporation\
        .includes(:sub_company)\
        .select(:sub_company_id, :id, :name, :full_name)\
        .sort_by{|nc| [nc.sub_company_id, nc.name]}\
        .reduce([]) do |ar, nc|
          ar << ["#{nc.sub_company.name} - #{nc.name}", nc.id]
        end
      hash = {
        'normal_corporation_id_合作单位' => corps,
        'in_contract_状态' => [ ['活动', true], ['解除', false] ],
        'contract_type_合同类型' => LaborContract.contract_types_option,
        'contract_start_date_合同起始日期' => :text,
        'contract_end_date_合同结束日期' => :text,
      }
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.labor_contract")}_#{Time.stamp}.xlsx"
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
                if col == :normal_staff_id
                  item.normal_staff.try(:name)
                elsif col == :sub_company_id
                  item.normal_corporation.try(:sub_company).try(:name)
                elsif col == :normal_corporation_id
                  item.normal_corporation.try(:name)
                elsif col == :in_contract
                  item.in_contract ? '活动' : '解除'
                elsif col == :contract_type
                  item.contract_type_i18n
                elsif [:has_social_insurance, :has_medical_insurance, :has_accident_insurance].include?(col)
                  item.send(col) ? '是的' : '无'
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

  def name
    "#{normal_corporation.name} - #{normal_staff.name}"
  end

  def contract_type_i18n
    ct = contract_type || :nil
    I18n.t("activerecord.attributes.labor_contract.contract_types.#{ct}")
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

    stats[:house_accumulation_personal] = house_accumulation_base * personal_rate.house_accumulation
    stats[:house_accumulation_company] = house_accumulation_base * company_rate.house_accumulation

    stats
  end

  def activate!
    update_attribute(:in_contract, true)
  end

  def inactivate!
    update_attribute(:in_contract, false)
  end

  def has_insurance?
    has_social_insurance || has_medical_insurance
  end

  ransacker :sub_company, formatter: ->(qid) {
    sub_company = SubCompany.find(qid)
    LaborContract.where( normal_corporation_id: sub_company.normal_corporations.pluck(:id) ).pluck(:id)
  } do |parent|
      parent.table[:id]
  end

  def due?
    return false if contract_end_date.nil?

    Date.today + 1.month >= contract_end_date
  end

  def copy_from(option)
    attrs = self.attributes.except('id', 'created_at', 'updated_at').merge(option)
    self.class.create!(attrs)
  end

  private

    def check_active_status
      if in_contract_change.try(:last) == true
        other_active_contracts = normal_staff.labor_contracts.where.not(id: self.id).active
        if other_active_contracts.count > 0
          # callbacks skipped
          other_active_contracts.each{|lc| lc.update_column(:in_contract, false)}
        end
      end
    end

    def check_relationship
      if self.in_contract && changed.include?('normal_corporation_id')
        normal_staff.update_attribute(:normal_corporation_id, self.normal_corporation_id)
        normal_staff.update_attribute(:sub_company_id, self.normal_corporation.sub_company_id)
      end
    end

    def check_staff_in_contract
      if changed.include? 'in_contract'
        if self.in_contract
          normal_staff.update_attribute(:in_contract, true) unless normal_staff.in_contract
        else
          if normal_staff.labor_contracts.active.count == 0 && normal_staff.in_contract
            normal_staff.update_attribute(:in_contract, false)
          end
        end
      end
    end

    def set_nest_index
      if changed.include? 'nest_index'
        if self.in_contract
          normal_staff.update_attribute(:nest_index, self.nest_index)
        end
      end
    end
end
