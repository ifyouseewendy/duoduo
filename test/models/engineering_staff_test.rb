require 'test_helper'

class EngineeringStaffTest < ActiveSupport::TestCase
  setup do
    @staff = engineering_staffs(:one)
    @project_two = engineering_projects(:two)
    @project_three = engineering_projects(:three)
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

end
