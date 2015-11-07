class EngineeringProject < ActiveRecord::Base
  belongs_to :engineering_customer
  belongs_to :engineering_corp
  has_and_belongs_to_many :engineering_staffs

  has_many :engineering_salary_tables, dependent: :destroy

  before_save :revise_fields

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(engineering_customer_id engineering_corp_id) if without_foreign_keys

      names
    end

    def columns_of(type)
      self.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end

    def batch_form_fields
      fields = ordered_columns(without_base_keys: true, without_foreign_keys: true)
      hash = {
        'engineering_customer_id_工程客户' => EngineeringCustomer.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]},
        'engineering_corp_id_工程单位' => EngineeringCorp.select(:id, :name).reduce([]){|ar, ele| ar << [ele.name, ele.id]}
      }
      fields.each{|k| hash[ "#{k}_#{human_attribute_name(k)}" ] = :text }
      hash
    end

    def export_xlsx(options: {})
      filename = "#{I18n.t("activerecord.models.#{name.underscore}")}_#{Time.stamp}.xlsx"
      filepath = EXPORT_PATH.join filename

      collection = self.all
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      booleans = columns_of(:boolean)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
               if [:engineering_customer, :engineering_corp].include? col
                  item.send(col).name
                elsif booleans.include? col
                  item.send(col) ? '是' : '否'
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
        %i(id name engineering_customer engineering_corp) \
          + (ordered_columns(without_foreign_keys: true) - %i(id name))
      end
    end
  end

  def revise_fields
    self.project_range ||= -> {
      month = (project_end_date.to_date - project_start_date.to_date).to_i / 28
      "#{month} 月"
    }.call

    if (changed && [:project_amount, :admin_amount]).present?
      self.total_amount = project_amount + admin_amount
    end
  end

  def range
    [project_start_date, project_end_date]
  end

  def range_output
    "项目：#{name}，起止日期：#{project_start_date} - #{project_end_date}"
  end

  def generate_salary_table(type:)
  end
end
