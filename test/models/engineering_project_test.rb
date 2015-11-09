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
    @project_one.generate_salary_table(need_count: 3)
    assert_equal 1, @project_one.engineering_salary_tables.count

    st = @project_one.engineering_salary_tables.first
    assert_equal "2015-09-01 ~ 2015-09-30", st.name

    assert_equal 3, st.salary_items.count
  end

  def test_generate_salary_table_for_less_than_one_month
    @project_two.generate_salary_table(need_count: 3)
    assert_equal 1, @project_two.engineering_salary_tables.count

    st = @project_two.engineering_salary_tables.first
    assert_equal "2015-10-01 ~ 2015-10-15", st.name

    assert_equal 3, st.salary_items.count
  end

  def test_generate_salary_table_for_more_than_one_month
    @project_three.generate_salary_table(need_count: 3)
    assert_equal 2, @project_three.engineering_salary_tables.count

    st_one, st_two = @project_three.engineering_salary_tables.to_a
    assert_equal "2015-09-15 ~ 2015-10-14", st_one.name
    assert_equal "2015-10-15 ~ 2015-10-30", st_two.name

    assert_equal 3, st_one.salary_items.count
    assert_equal 3, st_two.salary_items.count
  end
end
