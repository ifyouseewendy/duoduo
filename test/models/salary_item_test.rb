require 'test_helper'

class SalaryItemTest < ActiveSupport::TestCase

  test "find_staff" do
    st = salary_tables(:one)

    assert_raises RuntimeError, '没有找到关联员工，姓名' do
      SalaryItem.find_staff(salary_table: st, name: 'nobody')
    end

    assert_raises RuntimeError, '没有找到关联员工，身份证号' do
      SalaryItem.find_staff(salary_table: st, name: 'one', identity_card: '999')
    end

    assert_raises RuntimeError, '员工姓名与身份证号不相符' do
      SalaryItem.find_staff(salary_table: st, name: 'two', identity_card: '111')
    end

    staff_1 = SalaryItem.find_staff(salary_table: st, name: 'one')
    staff_2 = SalaryItem.find_staff(salary_table: st, name: 'one', identity_card: '111')

    assert_equal staff_1.id, staff_2.id
  end

  test "create_by" do
    st = salary_tables(:one)
    item = SalaryItem.create_by(salary_table: st, salary: 1000, name: 'one')

    assert_equal 100,   item.total_personal
    assert_equal 900,   item.salary_in_fact
    assert_equal 200,   item.total_company

    assert_equal 1200,  item.total_sum
    assert_equal 120,   item.admin_amount
    assert_equal 1320,  item.total_sum_with_admin_amount
  end
end
