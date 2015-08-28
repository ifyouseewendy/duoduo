class NormalStaff < ActiveRecord::Base
  belongs_to :normal_corporation

  enum gender: [:male, :female]

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end

    def genders_option
      genders.keys.map.with_index{|k,i| [I18n.t("activerecord.attributes.normal_staff.genders.#{k}"), i]}
    end

    def columns_of(type)
      NormalStaff.columns_hash.select{|k,v| v.type == type }.keys.map(&:to_sym)
    end
  end

  def gender_i18n
    I18n.t("activerecord.attributes.normal_staff.genders.#{gender}")
  end
end
