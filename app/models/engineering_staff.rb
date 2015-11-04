class EngineeringStaff < ActiveRecord::Base
  belongs_to :engineering_customer
  has_and_belongs_to_many :engineering_projects, before_add: :check_schedule
  has_many :salary_items

  enum gender: [:male, :female]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def genders_option
      genders.keys.map{|k| [I18n.t("activerecord.attributes.engineering_staff.genders.#{k}"), k]}
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: false)
      hash = fields.each_with_object({}){|k, ha| ha[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash['gender_性别'] = genders_option
      # hash['engineering_corporation_id_所属单位'] = EngineeringCorporation.reference_option
      hash
    end
  end

  def gender_i18n
    I18n.t("activerecord.attributes.engineering_staff.genders.#{gender}")
  end

  def company_name
    # engineering_corporation.name rescue ''
  end

  # Returns an Array of ranges, which range is represented by an Array of start_date and end_date
  def busy_range
    engineering_projects.select(:project_start_date, :project_end_date).map{|ep| [ ep.project_start_date, ep.project_end_date ]}.sort
  end

  def check_schedule(project)
    raise "Staff refuse the project schedule" unless accept_schedule?(*project.range)
  end

  def accept_schedule?(start_date, end_date)
    busy_range.all?{|range| range[0] > end_date.to_date || range[1] < start_date.to_date }
  end
end
