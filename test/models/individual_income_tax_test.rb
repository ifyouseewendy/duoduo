require 'test_helper'

class IndividualIncomeTaxTest < ActiveSupport::TestCase
  test "quick subtractor" do
    assert_equal [0,105,555,1005,2755,5505,13505], IndividualIncomeTax.order(grade: :asc).map(&:quick_subtractor).map(&:to_i)
  end
end
