class IndividualIncomeTax < ActiveRecord::Base
  include PublicActivity::Model
  tracked \
    owner: ->(controller, model) { controller.try(:current_admin_user) || AdminUser.super_admin.first },
    params: {
      name: ->(controller, model) { [model.class.model_name.human, model.try(:name)].compact.join(' - ') },
    }

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i() if without_foreign_keys

      names
    end

    def calculate(salary: 0, bonus: 0)
      ( salary_tax(salary: salary) + bonus_tax(salary: salary, bonus: bonus) ).round(2)
    end

    def salary_tax(salary: 0)
      base = IndividualIncomeTaxBase.instance.base
      number = salary - base

      return 0 if number <= 0

      iit = detect_rule_for(number)
      number * iit.rate - iit.quick_subtractor
    end

    def bonus_tax(salary: 0, bonus: 0)
      return 0 if bonus.to_f == 0

      base = IndividualIncomeTaxBase.instance.base
      number = salary > base ? bonus : (bonus + salary - base)
      number = 0 if number < 0

      iit = detect_rule_for(number / 12.0)
      number * iit.rate - iit.quick_subtractor
    end

    def detect_rule_for(number)
      self.order(grade: :asc).detect{|e| Range.new(e.tax_range_start, e.tax_range_end).include? number }
    end

  end

  def quick_subtractor
    return 0 if grade == 1

    iits = IndividualIncomeTax.where(grade: (1..grade))

    prev = iits[0]
    iits[1..-1].reduce(0) do |sum, iit|
      sum += iit.tax_range_start * ( iit.rate - prev.rate )
      prev = iit
      sum
    end
  end
end
