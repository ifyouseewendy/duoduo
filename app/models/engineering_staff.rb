class EngineeringStaff < ActiveRecord::Base
  belongs_to :customer, \
    class: EngineeringCustomer, \
    foreign_key: :engineering_customer_id, \
    required: true

  # TODO
  #
  #   Temp comment out check_schedule on importing stage
  #   Remember to check test/models/engineering_staff_test.rb:21
  has_and_belongs_to_many :projects, \
    class_name: EngineeringProject, \
    join_table: 'engineering_projects_staffs',
    before_add: :check_schedule

  has_many :engineering_normal_salary_items
  has_many :engineering_normal_with_tax_salary_items
  has_many :engineering_big_table_salary_items
  has_many :engineering_dong_fang_salary_items

  enum gender: [:male, :female]

  before_save :revise_fields

  validates_uniqueness_of :identity_card
  validates_presence_of :identity_card
  validates_length_of :identity_card, is: 18, message: "身份证号必须为18位"
  validates_inclusion_of :gender, in: %w(male female)

  default_scope { order(updated_at: :desc).order(enable: :desc) }
  scope :enabled, -> { where(enable: true) }
  scope :by_project, ->(project_id){
    joins("join engineering_projects_staffs on engineering_staffs.id = engineering_projects_staffs.engineering_staff_id")\
      .where("engineering_projects_staffs.engineering_project_id = ?", project_id)
  }

  class << self
    def policy_class
      EngineeringPolicy
    end

    def ordered_columns(without_base_keys: false, without_foreign_keys: false, export: false)
      if export
        names = [:identity_card, :name, :enable, :birth, :gender, :nation, :address, :remark, :engineering_customer_id]
      else
        names = column_names.map(&:to_sym)
        names -= %i(id alias_name created_at updated_at) if without_base_keys
        names -= %i(engineering_customer_id) if without_foreign_keys

        names
      end
    end

    def genders_option
      genders.keys.map{|k| [I18n.t("activerecord.attributes.engineering_staff.genders.#{k}"), k]}
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)
      hash = {
        'engineering_customer_id_工程客户' => EngineeringCustomer.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]},
      }
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash['gender_性别'] = genders_option
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.#{name.underscore}")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      if options[:selected].present?
        collection = collection.where(id: options[:selected])
      elsif options['projects_id_eq'].present?
        collection = collection.by_project(options['projects_id_eq'])
      elsif options['customer_id_eq'].present?
        collection = collection.where(engineering_customer_id: options['customer_id_eq'])
      else
      end

      columns = columns_based_on(options: options)

      genders_i18n = {'female' => '女', 'male' => '男'}
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
               if [:customer].include? col
                  item.send(col).name
               elsif [:gender].include? col
                  genders_i18n[ item.send(col) ]
               elsif [:identity_card].include? col
                  "'#{item.send(col)}"
               elsif [:enable].include? col
                 item.send(col) ? '可用' : '不可用'
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
        %i(identity_card name enable customer) \
          + (ordered_columns(without_base_keys: true, without_foreign_keys: true) - %i(id identity_card name enable alias_name))
      end
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
    [
      engineering_normal_salary_items,
      engineering_normal_with_tax_salary_items,
      engineering_big_table_salary_items,
      engineering_dong_fang_salary_items
    ].flat_map{|items| items.map{|item| item.salary_table.range} }.sort
  end

  def check_schedule(project)
    raise "<#{name}>已分配项目与项目<#{project.name}>时间重叠" unless accept_schedule?(*project.range)
  end

  def accept_schedule?(start_date, end_date)
    busy_range.all?{|range| range[0] > end_date.to_date || range[1] < start_date.to_date }
  end

  def revise_fields
    if (changed & ['identity_card']).present?
      id_card = self.identity_card
      begin
        self.birth = Date.parse(id_card[6,8])
        if self.birth + 18.years > Date.today
          errors.add(:birth, "员工未满十八周岁")
        end
      rescue => _
        errors.add(:birth, "无法通过身份证号获取生日信息，请检查身份证号：#{id_card}")
      end
    end
  end

  def age
    return '' if birth.blank?

    num = Date.today.year - birth.year
    (birth + num.years >= Date.today) ? num-1 : num
  end

  def seal_index
    SealItem.query_user(name: name)
  end
end
