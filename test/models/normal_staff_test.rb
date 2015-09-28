require 'test_helper'

class NormalStaffTest < ActiveSupport::TestCase
  test "insurance_fund without social and medical insurance" do
    insurance_fund = normal_staffs(:one).insurance_fund

    assert_equal 0,   insurance_fund[:unemployment_personal]
    assert_equal 0,   insurance_fund[:medical_personal]
    assert_equal 0,   insurance_fund[:injury_company]
    assert_equal 100, insurance_fund[:house_accumulation_personal]
  end

  test "insurance_fund with social only" do
    insurance_fund = normal_staffs(:two).insurance_fund

    assert_equal 20,   insurance_fund[:unemployment_personal]
    assert_equal 0,    insurance_fund[:medical_personal]
    assert_equal 30,   insurance_fund[:injury_company]
    assert_equal 100,  insurance_fund[:house_accumulation_personal]
  end

  test "insurance_fund with social and medical both" do
    insurance_fund = normal_staffs(:three).insurance_fund

    assert_equal 20,   insurance_fund[:unemployment_personal]
    assert_equal 50,   insurance_fund[:medical_personal]
    assert_equal 30,   insurance_fund[:injury_company]
    assert_equal 100,  insurance_fund[:house_accumulation_personal]
  end
end
