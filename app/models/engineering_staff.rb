class EngineeringStaff < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :customer, \
    class: EngineeringCustomer, \
    foreign_key: :engineering_customer_id, \
    required: true

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
  before_destroy :remove_salary_items

  validates_uniqueness_of :identity_card
  validates_presence_of :identity_card
  validates_length_of :identity_card, is: 18, message: "身份证号必须为18位"
  validates_inclusion_of :gender, in: %w(male female)

  default_scope { order(created_at: :asc).order(enable: :desc) }
  scope :enabled, -> { where(enable: true) }
  scope :disabled, -> { where.not(enable: true) }
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
        names = [:identity_card, :name, :gender, :remark]
      else
        names = column_names.map(&:to_sym)
        names -= %i(id alias_name created_at updated_at) if without_base_keys
        names -= %i(engineering_customer_id) if without_foreign_keys

        names
      end
    end

    def genders_option(filter: false)
      if filter
        genders.map{|k,v| [I18n.t("activerecord.attributes.engineering_staff.genders.#{k}"), v]}
      else
        genders.keys.map{|k| [I18n.t("activerecord.attributes.engineering_staff.genders.#{k}"), k]}
      end
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_fields
      [
        :remark
      ]
    end

    def batch_form_fields
      fields = batch_fields
      hash = {
        'engineering_customer_id_所属客户' => EngineeringCustomer.as_option(available_project: false),
        'enable_状态' => [ ['可用', true], ['不可用', false] ],
        'gender_性别' => [ ['男', 'male'], ['女', 'female'] ],
      }
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

      if options['projects_id_eq'].present?
        project_used = true
        header = '用工明细表'
        columns = [:id, :name, :gender, :identity_card]
      else
        header = '提供人员表'
        columns = columns_based_on(options: options)
      end

      data_types = columns.reduce([]) do |ar, col|
        if col == :identity_card
          ar << :string
        else
          ar << nil
        end
      end

      genders_i18n = {'female' => '女', 'male' => '男'}
      Axlsx::Package.new do |p|
        wb = p.workbook
        wrap_header_first = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          b: true,
          sz: 18
        })
        wrap_header_second = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          border: {style: :thin, color: '00'},
          b: true,
          sz: 16
        })
        wrap_text = wb.styles.add_style({
          font_name: "新宋体",
          alignment: {horizontal: :center, vertical: :center, wrap_text: true},
          border: {style: :thin, color: '00'},
          height: 30,
          sz: 12
        })
        margins = {left: 0.8, right: 0.8, top: 0.8, bottom: 0.8}

        sheet_name = header
        wb.add_worksheet(name: sheet_name, page_margins: margins) do |sheet|
          # Fit to page printing
          sheet.page_setup.fit_to :width => 1

          # Headers
          sheet.add_row [header], height: 40, style: wrap_header_first
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}, \
            height: 30, style: wrap_header_second

          end_col = ('A'.ord + columns.count - 1).chr
          sheet.merge_cells("A1:#{end_col}1")

          # Content
          collection.each_with_index do |item, idx|
            stats = \
              columns.map do |col|
               if [:customer].include? col
                  item.send(col).name
               elsif [:gender].include? col
                  genders_i18n[ item.send(col) ]
               elsif [:identity_card].include? col
                  "#{item.send(col)}"
               elsif [:enable].include? col
                 item.send(col) ? '可用' : '不可用'
               elsif [:id].include?(col)
                 idx+1
               else
                 item.send(col)
               end
              end
            sheet.add_row stats, style: ( [wrap_text]*columns.count ), height: 30, types: data_types
          end

          if project_used
            sheet.column_widths 15, 15, 15, 30
          end

          wb.add_defined_name("'#{sheet_name}'!$1:$2", :local_sheet_id => sheet.index, :name => '_xlnm.Print_Titles') 
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
    raise "<#{name}>已分配给项目<#{project.display_name}>，无法重复分配" if projects.pluck(:id).include?(project.id)
    raise "<#{name}>已分配项目与项目<#{project.display_name}>时间重叠" unless accept_schedule?(*project.range)
  end

  def accept_schedule?(start_date, end_date)
    if birth.present?
      return false if start_date < birth + 18.years
    end
    busy_range.all?{|range| range[0] > end_date.to_date || range[1] < start_date.to_date }
  end

  def revise_fields
    if (changed & ['identity_card']).present?
      id_card = self.identity_card
      begin
        self.birth = Date.parse(id_card[6,8])
        if self.birth + 18.years > Date.today
          errors.add(:birth, "员工未满十八周岁")
          return false
        elsif self.birth + 60.years < Date.today
          errors.add(:birth, "员工超过六十岁")
          return false
        end
      rescue => _
        errors.add(:birth, "无法通过身份证号获取生日信息，请检查身份证号：#{id_card}")
        return false
      end
    end
    if (changed & ['name']).present?
      self.seal_index = query_seal_index
    end
  end

  def age
    return '' if birth.blank?

    num = Date.today.year - birth.year
    (birth + num.years >= Date.today) ? num-1 : num
  end

  def query_seal_index
    st_name = SealItem.query_user(name: name) # "108、陈连春提供22人"
    nm = st_name.to_s.match(/^[\d|\-]*/)[0] # "108"
    nm.present? ? nm : st_name
  end

  def validate_seal_index
    self.update_attribute(:seal_index, query_seal_index)
  end

  def remove_salary_items
    [
      engineering_normal_salary_items,
      engineering_normal_with_tax_salary_items,
      engineering_big_table_salary_items,
      engineering_dong_fang_salary_items
    ].each(&:destroy_all)
  end
end
