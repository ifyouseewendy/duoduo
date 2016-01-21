class NormalCorporation < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :sub_company, required: true
  has_many :contract_files, dependent: :destroy, as: :busi_contract

  has_many :labor_contracts
  has_many :normal_staffs

  has_many :salary_tables
  has_many :salary_items, through: :salary_tables
  has_many :guard_salary_tables
  has_many :guard_salary_items, through: :guard_salary_tables
  has_many :non_full_day_salary_tables
  has_many :non_full_day_salary_items, through: :non_full_day_salary_tables

  validates_uniqueness_of :name

  default_scope { order(sub_company_id: :asc) }
  scope :updated_in_7_days, ->{ where('updated_at > ?', Date.today - 7.days) }
  scope :updated_latest_10, ->{ order(updated_at: :desc).limit(10) }

  enum admin_charge_type: [
    :unset,
    :by_count,  # 固定
    :by_rate_a, # 比例（应发）
    :by_rate_b, # 比例（应发+单位缴费）
    :by_rate_c, # 比例（劳务费合计）
    :by_rate_d, # 比例（应发+意外险）
    :by_rate_e, # 比例（应发+意外险+工伤+管理费+其他）
  ]
  enum status: [:active, :archive]

  after_save :check_sub_company

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(sub_company_id) if without_foreign_keys

      names
    end

    def admin_charge_types_option
      admin_charge_types.keys.map{|k| [I18n.t("activerecord.attributes.normal_corporation.admin_charge_types.#{k}"), k]}
    end

    def as_filter
      self.active.includes(:sub_company).select(:sub_company_id, :name, :id).order(sub_company_id: :asc, name: :asc).map do |nc|
        name = nc.name
        name = "#{nc.sub_company.name} - #{nc.name}" if nc.sub_company.present?
        [name, nc.id]
      end
    end

    def batch_form_fields
      hash = {
        'sub_company_ids_吉易子公司' => SubCompany.select(:id, :name).reduce([]){|ar, sc| ar << [sc.name, sc.id] },
        'status_状态' => statuses_option,
        'admin_charge_type_管理费收取方式' => admin_charge_types_option,
        'admin_charge_amount_管理费收取金额' => :text,
        'full_name_单位全称' => :text,
      }
      fields = [
        :expense_date,
        :contract_start_date,
        :contract_end_date,
        :remark
      ]
      # fields = ordered_columns(without_base_keys: true, without_foreign_keys: true) - [:name, :status, :admin_charge_type, :admin_charge_amount]
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

    def reference_option
      order(id: :asc).pluck(:name, :id)
    end

    def statuses_option
      statuses.keys.map{|k| [I18n.t("activerecord.attributes.#{self.name.underscore}.statuses.#{k}"), k]}
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.normal_corporation")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                if col == :admin_charge_type
                  item.send(:admin_charge_type_i18n)
                else
                  item.send(col)
                end
              end
              sheet.add_row stats
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
        %i(id name) \
          + %i(sub_company_id stuff_count stuff_has_insurance_count) \
          + (NormalCorporation.ordered_columns(without_foreign_keys: true) - %i(id name) )
      end
    end

    def internal
      @_internal ||= where(name: '内部').first
    end

  end

  def admin_charge_type_i18n
    I18n.t("activerecord.attributes.normal_corporation.admin_charge_types.#{admin_charge_type}")
  end

  def by_rate?
    by_rate_on_salary? || by_rate_on_salary_and_company?
  end

  def stuff_count
    normal_staffs.count
  end

  def stuff_has_insurance_count
    normal_staffs.includes(:labor_contracts).select(&:has_insurance?).count
  end

  def status_i18n
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.statuses.#{status}")
  end

  def check_sub_company
    if changed.include? 'sub_company_id'
      self.normal_staffs.update_all(sub_company_id: self.sub_company_id)
    end
  end

  def find_staff(name:, identity_card: nil)
    if identity_card.present?
      staff = normal_staffs.where(identity_card: identity_card).first
      raise "没有找到员工，身份证号：#{identity_card}" if staff.nil?
      raise "员工姓名与身份证号不相符，姓名：#{name}，身份证号：#{identity_card}" if name.present? && name != staff.name
    else
      raise "找到多个员工，重复姓名：#{name}，请附加一列身份证号" if normal_staffs.where(name: name).count > 1

      staff = normal_staffs.where(name: name).first
      raise "没有找到员工，姓名：#{name}" if staff.nil?
    end

    staff
  end

end
