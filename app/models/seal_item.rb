class SealItem < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  belongs_to :seal_table, required: true

  validates_uniqueness_of :nest_index, scope: :seal_table

  before_save :revise_fields
  after_save :revise_staff_seal_index

  class << self
    def policy_class
      EngineeringPolicy
    end

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

  def revise_fields
    self.nest_index ||= seal_table.try(:latest_item_index)
    self.name = self.name.strip
  end

  def revise_staff_seal_index
    if (changed & ['name']).present?
      before, after = changes[:name]
      EngineeringStaff.where(name: before).map(&:validate_seal_index) if before.present?
      EngineeringStaff.where(name: after).map(&:validate_seal_index)
    end
  end
end
