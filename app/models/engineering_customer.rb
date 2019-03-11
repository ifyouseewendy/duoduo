class EngineeringCustomer < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:display_name)].compact.join(' - ') },
    }

  has_many :projects, class: EngineeringProject,  dependent: :destroy
  has_many :staffs,   class: EngineeringStaff,    dependent: :destroy

  default_scope { order(nest_index: :desc) }

  validates_uniqueness_of :nest_index

  class << self
    def policy_class
      EngineeringCustomerPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)
      hash = {}
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.#{name.underscore}")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      if options[:selected].present?
        collection = collection.where(id: options[:selected])
      else
        collection = collection.ransack(options).result
      end

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                item.send(col)
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
        cols = ordered_columns(without_base_keys: true, without_foreign_keys: true)
        [:nest_index] + (cols - [:nest_index])
      end
    end

    def available_nest_index
      self.first.nest_index + 1
    end

    def as_option(available_project: true)
      if available_project
        self.select(:id, :nest_index, :name).map do |ec|
          [ec.display_name, ec.id, {'data-project-index': ec.available_project_nest_index}]
        end
      else
        self.select(:id, :nest_index, :name).map do |ec|
          [ec.display_name, ec.id]
        end
      end
    end
  end

  def pre_calculate_ranges(es_ids)
    ranges = Hash.new { |h, k| h[k] = [] }
    [
      EngineeringNormalSalaryItem,
      EngineeringNormalWithTaxSalaryItem,
      EngineeringBigTableSalaryItem,
      EngineeringDongFangSalaryItem
    ].each do |klass|
      klass.includes(:salary_table).where(engineering_staff_id: es_ids).each do |item|
        ranges[item.engineering_staff_id] << item.salary_table.range
      end
    end

    ranges.keys.each do |k|
      ranges[k].sort!
    end

    ranges
  end

  def pre_calculate_project_ids(es_ids)
    project_ids = Hash.new { |h, k| h[k] = [] }

    EngineeringProjectsStaff.where(engineering_staff_id: es_ids).each do |eps|
      project_ids[eps.engineering_staff_id] << eps.engineering_project_id
    end

    project_ids
  end

  def free_staffs(start_date, end_date, exclude_project_id: nil, count: nil)
    count ||= staffs.enabled.count

    if exclude_project_id.present?
      criteria = customer.staffs.enabled

      es_ids = criteria.pluck(:id)
      project_ids = pre_calculate_project_ids(es_ids)
      ranges = pre_calculate_ranges(es_ids)

      criteria.lazy.select {|es|
        !(project_ids[es.id].include? project_id) \
          && es.accept_schedule_with_time_range?(start_date, end_date, ranges[es.id])
      }.first(count)

    else
      criteria = staffs.enabled
      criteria.lazy.select {|es|
        es.accept_schedule?(start_date, end_date).nil?
      }.first(count)
    end
  end

  def sub_companies
    ids = projects.pluck(:sub_company_id)
    SubCompany.where(id: ids)
  end

  def corporations
    ids = projects.pluck(:engineering_corp_id)
    EngineeringCorp.where(id: ids)
  end

  def display_name
    [nest_index, name].join('、')
  end

  ransacker :sub_company, formatter: ->(qid) {
    sub_company = SubCompany.find(qid)
    sub_company.projects.pluck(:engineering_customer_id).compact.uniq
  } do |parent|
      parent.table[:id]
  end

  # Allow nested routes for engineering_customer
  def engineering_projects
    projects
  end
  def engineering_staffs
    staffs
  end

  def available_project_nest_index
    ( self.projects.last.try(:nest_index) || 0 ) + 1
  end

end
