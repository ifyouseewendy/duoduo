require 'test_helper'

class IndividualIncomeTaxTest < ActiveSupport::TestCase
  test "quick subtractor" do
    assert_equal [0,105,555,1005,2755,5505,13505], IndividualIncomeTax.order(grade: :asc).map(&:quick_subtractor).map(&:to_i)
  end

  test "base on salary" do
    assert_equal 45,        IndividualIncomeTax.calculate(salary: 5000)
    assert_equal 45.1,      IndividualIncomeTax.calculate(salary: 5000.99)
    assert_equal 745,       IndividualIncomeTax.calculate(salary: 10000)
    assert_equal 745.11,    IndividualIncomeTax.calculate(salary: 10000.55)
    assert_equal 74920,     IndividualIncomeTax.calculate(salary: 200000)
    assert_equal 74920.3,   IndividualIncomeTax.calculate(salary: 200000.66)
  end

  test "base on salary + bonus" do
    assert_equal 105,   IndividualIncomeTax.calculate(salary: 2000, bonus: 5000)
    assert_equal 1745,  IndividualIncomeTax.calculate(salary: 2000, bonus: 20000)
    assert_equal 195,   IndividualIncomeTax.calculate(salary: 5000, bonus: 5000)
    assert_equal 1940,  IndividualIncomeTax.calculate(salary: 5000, bonus: 20000)
  end
end
