require 'test_helper'

class EngineeringCorpTest < ActiveSupport::TestCase
  setup do
    @one = engineering_corps(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end

  def test_ref_with_sub_companies
    assert_equal [sub_companies(:one).id], @one.sub_companies.pluck(:id)
  end

  def test_ref_with_customers
    assert_equal [engineering_customers(:one).id], @one.customers.pluck(:id)
  end

end
