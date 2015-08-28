class NormalStaff < ActiveRecord::Base
  belongs_to :normal_corporation

  enum gender: [:male, :female]

  class << self
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
