require 'test_helper'

class EngineeringOutcomeItemTest < ActiveSupport::TestCase
  test "allocate" do
    assert_equal [34.1, 33, 33], engineering_outcome_items(:one).allocate(money: 100.1)
  end
end
