require 'test_helper'

class EngineeringStaffTest < ActiveSupport::TestCase
  setup do
    @staff = engineering_staffs(:one)
    @project_one = engineering_projects(:one)
    @project_two = engineering_projects(:two)
    @project_three = engineering_projects(:three)
  end

  def test_ref_with_customer
    assert_equal engineering_customers(:one).id, @staff.customer.id
  end

  def test_busy_range
    assert_equal [['2015-01-01', '2015-01-31'], ['2015-02-01', '2015-02-28']], @staff.busy_range.map{|ar| ar.map(&:to_s)}
  end

  def test_check_schedule_when_appending_new_project
    # Dont change busy_range when appending new project,
    # only change by setting salary_table
    assert_silent do
      @staff.engineering_projects << @project_two
    end
    assert_equal 2, @staff.busy_range.count

    # TODO
    #
    #   Temp comment out check_schedule on importing stage
    #
    # assert_raises RuntimeError, /时间重叠/ do
    #   @staff.engineering_projects << @project_three
    # end
    # assert_equal 2, @staff.busy_range.count
  end

  def test_split_range
    @project_one.project_start_date = '2015-01-01'
    @project_one.project_end_date = '2015-02-15'

    range = @project_one.split_range
    assert_equal 1, range.count
    assert_equal ['2015-01-01', '2015-01-31'], range.last.map(&:to_s)

    range = @project_one.split_range(2)
    assert_equal ['2015-01-01', '2015-01-31'], range.first.map(&:to_s)
    assert_equal ['2015-02-01', '2015-02-15'], range.last.map(&:to_s)

    range = @project_one.split_range(3)
    assert_equal ['2015-01-01', '2015-01-31'], range.first.map(&:to_s)
    assert_equal ['2015-02-01', '2015-02-15'], range.last.map(&:to_s)

    @project_one.project_start_date = '2015-01-01'
    @project_one.project_end_date = '2015-04-05'

    range = @project_one.split_range
    assert_equal 3, range.count
    assert_equal ['2015-03-01', '2015-03-31'], range.last.map(&:to_s)

    range = @project_one.split_range(1)
    assert_equal 1, range.count
    assert_equal ['2015-01-01', '2015-04-05'], range.last.map(&:to_s)

    range = @project_one.split_range(2)
    assert_equal 2, range.count
    assert_equal ['2015-02-01', '2015-04-05'], range.last.map(&:to_s)

    range = @project_one.split_range(4)
    assert_equal 4, range.count
    assert_equal ['2015-04-01', '2015-04-05'], range.last.map(&:to_s)
  end

end
