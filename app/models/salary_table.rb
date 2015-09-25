class SalaryTable < ActiveRecord::Base
  belongs_to :normal_corporation
  has_many :salary_items, dependent: :destroy

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(normal_corporation_id) if without_foreign_keys

      names
    end
  end

  def corporation
    normal_corporation
  end
end
