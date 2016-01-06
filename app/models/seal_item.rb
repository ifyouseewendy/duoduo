class SealItem < ActiveRecord::Base
  belongs_to :seal_table, required: true

  validates_uniqueness_of :nest_index, scope: :seal_table

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(seal_table_id) if without_foreign_keys

      names
    end

    def query_user(name:)
      where(name: name.strip).first.try(:seal_table).try(:name)
    end

  end

end
