class LaborContract < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :normal_corporation
  belongs_to :normal_staff
end
