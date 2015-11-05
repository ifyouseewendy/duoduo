require 'test_helper'

class EngineeringStaffTest < ActiveSupport::TestCase
  setup do
    @staff = engineering_staffs(:one)
    @project_two = engineering_projects(:two)
    @project_three = engineering_projects(:three)
  end

  def test_busy_range
    assert_equal [['2015-09-01', '2015-09-30']], @staff.busy_range.map{|ar| ar.map(&:to_s)}
  end

  def test_check_schedule_when_appending_new_project
    assert_silent do
      @staff.engineering_projects << @project_two
    end
    assert_equal 2, @staff.busy_range.count
    assert_equal ['2015-10-01', '2015-10-31'], @staff.busy_range.last.map(&:to_s)

    assert_raises RuntimeError, /时间重叠/ do
      @staff.engineering_projects << @project_three
    end
    assert_equal 2, @staff.busy_range.count
  end

end
