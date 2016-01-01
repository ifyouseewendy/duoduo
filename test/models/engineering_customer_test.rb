require 'test_helper'

class EngineeringCustomerTest < ActiveSupport::TestCase
  setup do
    @one = engineering_customers(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end

  def test_ref_with_sub_companies
    assert_equal [sub_companies(:one).id], @one.sub_companies.pluck(:id)
  end

  def test_ref_with_corporations
    assert_equal [engineering_corps(:one).id], @one.corporations.pluck(:id)
  end
end
