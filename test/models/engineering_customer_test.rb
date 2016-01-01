require 'test_helper'

class EngineeringCustomerTest < ActiveSupport::TestCase
  setup do
    @one = engineering_customers(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end
end
