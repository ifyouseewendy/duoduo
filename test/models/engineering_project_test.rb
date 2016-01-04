require 'test_helper'

class EngineeringProjectTest < ActiveSupport::TestCase
  setup do
    @project = EngineeringProject.new
    @project_one = engineering_projects(:one)
    @project_two = engineering_projects(:two)
    @project_three = engineering_projects(:three)
  end

  def test_ref_with_sub_company
    assert_equal sub_companies(:one).id, @project_one.sub_company.id
  end

  def test_ref_with_customer
    assert_equal engineering_customers(:one).id, @project_one.customer.id
  end

  def test_ref_with_corporation
    assert_equal engineering_corps(:one).id, @project_one.corporation.id
  end

  def test_ref_with_staffs
    assert_equal 3, @project_one.staffs.count
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
    @project_one.generate_salary_table(need_count: 3)
    assert_equal 1, @project_one.salary_tables.count

    st = @project_one.salary_tables.first
    assert_equal "2015-09-01 ~ 2015-09-30", st.name

    assert_equal 3, st.salary_items.count
  end

  def test_generate_salary_table_for_less_than_one_month
    skip
    @project_two.generate_salary_table(need_count: 3)
    assert_equal 1, @project_two.salary_tables.count

    st = @project_two.salary_tables.first
    assert_equal "2015-10-01 ~ 2015-10-15", st.name

    assert_equal 3, st.salary_items.count
  end

  def test_generate_salary_table_for_more_than_one_month
    skip
    @project_three.generate_salary_table(need_count: 3)
    assert_equal 2, @project_three.salary_tables.count

    st_one, st_two = @project_three.salary_tables.to_a
    assert_equal "2015-09-15 ~ 2015-10-14", st_one.name
    assert_equal "2015-10-15 ~ 2015-10-30", st_two.name

    assert_equal 3, st_one.salary_items.count
    assert_equal 3, st_two.salary_items.count
  end
end
