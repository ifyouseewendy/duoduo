class GuardSalaryItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:staff_name)].compact.join(' - ') },
    }

  belongs_to :guard_salary_table
  belongs_to :normal_staff

  enum role: ['normal', 'transfer']

  before_create :auto_init_fields, unless: -> { @skip_callbacks == true }

  after_save :revise_fields

  # update nest_index on table's other salary_items
  after_destroy :revise_nest_index

  default_scope { order(nest_index: :asc).order(role: :asc) }

  class << self
    def policy_class
      BusinessPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        [:staff_name, :salary_deserve, :identity_card]
      else
        names = column_names.map(&:to_sym)

        names -= %i(id created_at updated_at) if without_base_keys
        names -= %i(normal_staff_id guard_salary_table_id) if without_foreign_keys

        names
      end
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = whole_columns - \
        [
          :nest_index,
          :staff_name,
          :salary_deserve,
          :total_deduct,
          :salary_in_fact,
          :total_sum,
          :balance
        ]

      fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def columns_based_on(view: nil, custom: nil)
      view ||= :whole

      case view.to_s
      when 'proof', 'card', 'whole'
        self.send("#{view}_columns")
      when 'custom'
        custom.to_s.strip.split('-').map(&:to_sym)
      else
        raise "Unsupported view: #{view}"
      end
    end

    def whole_columns
      [
        # 员工信息
        :nest_index,
        :station,
        :staff_account,
        :staff_name,

        # 基本工资
        :income,
        :salary_base,
        :festival,
        :overtime,
        :exam,
        :duty,
        :salary_deserve,

        # 扣款
        :dress_deduct,
        :physical_exam_deduct,
        :pre_deduct,
        :total_deduct,

        # 实发工资
        :salary_in_fact,

        # 单位缴费
        :accident_insurance,

        # 劳务费
        :total_sum,
        :balance,

        :remark,
      ]
    end

    def card_columns
      [:nest_index, :staff_account, :staff_name, :salary_in_fact]
    end

    def proof_columns
      whole_columns\
        - [:income, :balance]
    end

    # To calculate total_company
    def company_deduct_fields
      []
    end

    def manipulate_insurance_fund_fields
      company_deduct_fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
    end

    def income_tax_fields
      []
    end

    def sum_fields
      whole_columns - [:nest_index, :station, :staff_account, :staff_name, :remark]
    end
  end # Class method ends

  def staff_identity_card
  end

  def corporation
    normal_staff.normal_corporation
  end

  def normal_staff_name
    normal_staff.name
  end

  def salary_table_name
    salary_table.name
  end

  def auto_init_fields
    return if self.transfer?

    set_name_and_account
    set_nest_index
  end

  def revise_fields
    # salary_deserve
    if (self.changed & ['salary_base', 'festival', 'overtime', 'exam', 'duty']).present?
      self.salary_deserve = (salary_base.to_f + festival.to_f + overtime.to_f\
                             - exam.to_f - duty.to_f).round(2)
    end

    # total_deduct
    if (self.changed & ['dress_deduct', 'physical_exam_deduct', 'pre_deduct']).present?
      self.total_deduct = (dress_deduct.to_f + physical_exam_deduct.to_f + pre_deduct.to_f).round(2)
    end

    # salary_in_fact
    if (self.changed & ['salary_deserve', 'total_deduct']).present?
      self.salary_in_fact = (self.salary_deserve.to_f - self.total_deduct.to_f).round(2)
    end

    # total_sum
    if (self.changed & ['salary_deserve', 'accident_insurance']).present?
      self.total_sum = (self.salary_deserve.to_f + self.accident_insurance.to_f).round(2)
    end

    # balance
    if (self.changed & ['income', 'total_sum']).present?
      self.balance = (self.income.to_f - self.total_sum.to_f).round(2)
    end

    self.update_columns(self.attributes)
  end

  def revise_nest_index
    return if siblings.count > 0

    self.salary_table.salary_items.where("nest_index > ?", self.nest_index).each do |si|
      si.update_column(:nest_index, si.nest_index - 1)
    end
  end

  def transfer_sibling
    salary_table.salary_items.transfer.where(nest_index: self.nest_index).first
  end

  def normal_sibling
    salary_table.salary_items.normal.where(nest_index: self.nest_index).first
  end

  def siblings
    salary_table.salary_items.where(nest_index: self.nest_index).where.not(id: self.id)
  end

  def set_name_and_account
    self.staff_name = self.normal_staff.name
    self.staff_account = self.normal_staff.account
  end

  def set_nest_index
    if self.role.to_sym == :normal
      self.nest_index = self.salary_table.available_nest_index
    end
  end

  def salary_table
    guard_salary_table
  end

end
