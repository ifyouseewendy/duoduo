require 'test_helper'

class EngineeringNormalWithTaxSalaryItemTest < ActiveSupport::TestCase
  test "revise_fields" do
    item = engineering_normal_with_tax_salary_items(:one)

    item.social_insurance += 10

    assert_difference ['item.total_insurance', 'item.total_amount'], 10 do
      item.save!
    end
  end
end
