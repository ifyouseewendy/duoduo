require 'test_helper'

class SalaryItemTest < ActiveSupport::TestCase

  test "create_by" do
    st = salary_tables(:one)

    assert_raises RuntimeError, 'No staff found' do
      SalaryItem.create_by(name: 'nobody', salary: 1000, salary_table: st)
    end

    item = SalaryItem.create_by(name: 'one', salary: 1000, salary_table: st)

    assert_equal 100,   item.total_personal
    assert_equal 900,   item.salary_in_fact
    assert_equal 200,   item.total_company
    assert_equal 1200,  item.total_sum
    assert_equal 120,   item.admin_amount
    assert_equal 1320,  item.total_sum_with_admin_amount
  end
end
