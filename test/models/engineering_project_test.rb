require 'test_helper'

class EngineeringProjectTest < ActiveSupport::TestCase
  setup do
    @project = EngineeringProject.new
    @project_one = engineering_projects(:one)
    @project_two = engineering_projects(:two)
    @project_three = engineering_projects(:three)
  end

  def test_gennerate_random_salary
    amount = 100000
    ar = @project.gennerate_random_salary(amount: amount, count: 33)
    assert_equal amount, ar.sum.to_i
    assert ar.detect{|i| i > 3500}.nil?

    amount = 115500
    ar = @project.gennerate_random_salary(amount: amount, count: 33) # 115500/33 == 3500
    assert_equal amount, ar.sum.to_i
    assert ar.detect{|i| i > 3500}.nil?

    amount = 115499
    ar = @project.gennerate_random_salary(amount: amount, count: 33)
    assert_equal amount, ar.sum.to_i
    assert ar.detect{|i| i > 3500}.nil?

    amount = 115501
    assert_raises RuntimeError, /too big/ do
      @project.gennerate_random_salary(amount: amount, count: 33)
    end
  end

  def test_generate_salary_table_for_one_month
    skip
  end
end
