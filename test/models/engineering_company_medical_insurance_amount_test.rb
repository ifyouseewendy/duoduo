require 'test_helper'

class EngineeringCompanyMedicalInsuranceAmountTest < ActiveSupport::TestCase
  test "current" do
    assert_equal 3, EngineeringCompanyMedicalInsuranceAmount.current.amount
  end

  test "query_amount" do
    assert_equal 2, EngineeringCompanyMedicalInsuranceAmount.query_amount(date: '2015-02-15')
  end
end
