require 'test_helper'

class EngineeringNormalSalaryItemTest < ActiveSupport::TestCase
  test "revise_fields" do
    item = engineering_normal_salary_items(:one)

    item.social_insurance += 10

    assert_difference ->{ item.total_insurance.to_f }, 10 do
      item.save!
    end

    item.social_insurance -= 10
    item.salary_in_fact += 10

    assert_difference ->{ item.salary_deserve.to_f }, 20 do
      item.save!
    end

  end
end
