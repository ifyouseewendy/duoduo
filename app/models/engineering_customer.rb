class EngineeringCustomer < ActiveRecord::Base
  has_many :engineering_projects, dependent: :destroy
  has_many :engineering_staffs, dependent: :destroy

  class << self
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
  end

  def free_staffs(start_date, end_date)
    engineering_staffs.select{|es| es.accept_schedule?(start_date, end_date)}
  end
end
