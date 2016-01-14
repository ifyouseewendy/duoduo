class EngineeringCustomer < ActiveRecord::Base
  has_many :projects, class: EngineeringProject,  dependent: :destroy
  has_many :staffs,   class: EngineeringStaff,    dependent: :destroy

  default_scope { order(nest_index: :desc) }

  validates_uniqueness_of :nest_index

  class << self
    def policy_class
      EngineeringPolicy
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
      collection = collection.where(id: options[:selected]) if options[:selected].present?

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

  def free_staffs(start_date, end_date, exclude_project_id: nil, count: nil)
    count ||= staffs.enabled.count

    if exclude_project_id.present?
      criteria = staffs.enabled.includes(:projects)
      criteria.lazy.select {|es|
        !(es.projects.select(:id).pluck(:id).include? exclude_project_id) \
          && es.accept_schedule?(start_date, end_date)
      }.first(count)

    else
      criteria = staffs.enabled
      criteria.lazy.select {|es|
        es.accept_schedule?(start_date, end_date)
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
