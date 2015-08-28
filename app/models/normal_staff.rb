class NormalStaff < ActiveRecord::Base
  belongs_to :normal_corporation

  enum gender: [:male, :female]

  class << self
    def genders_option
      genders.keys.map.with_index{|k,i| [I18n.t("activerecord.attributes.normal_staff.genders.#{k}"), i]}
    end
  end
end
