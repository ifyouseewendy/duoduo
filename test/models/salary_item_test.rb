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

    assert_equal 216,   item.total_personal
    assert_equal 784,   item.salary_in_fact
    assert_equal 200,   item.total_company

    assert_equal 1200,  item.total_sum
    assert_equal 120,   item.admin_amount
    assert_equal 1320,  item.total_sum_with_admin_amount
  end

  test "update_by without salary_deserve change" do
    st = salary_tables(:one)
    item = SalaryItem.create_by(salary_table: st, salary: 1000, name: 'one')

    stats = {
      pension_margin_personal: 100,
      medical_scan_addition: 200
    }

    item.update_by(stats)
    assert_equal 216 + 300,   item.total_personal
    assert_equal 784 - 300,   item.salary_in_fact
    assert_equal 200,   item.total_company

    assert_equal 1200,  item.total_sum
    assert_equal 120,   item.admin_amount
    assert_equal 1320,  item.total_sum_with_admin_amount

    stats = {
      pension_margin_personal: 100,
      insurance_pre_deduct_addition: 200,
      birth_company: 100,
      admin_amount: 200
    }

    item.update_by(stats)
    assert_equal 216 + 300,   item.total_personal
    assert_equal 784 - 300,   item.salary_in_fact
    assert_equal 200 + 100,   item.total_company

    assert_equal 1200 + 100,  item.total_sum
    assert_equal 200,   item.admin_amount
    assert_equal 1500,  item.total_sum_with_admin_amount
  end

  test "update_by with salary_deserve change" do
    st = salary_tables(:one)
    item = SalaryItem.create_by(salary_table: st, salary: 1000, name: 'one')

    stats = {
      salary_deserve: 5000,
      pension_margin_personal: 100,
      medical_scan_addition: 200,
      birth_company: 100,
      admin_amount: 200
    }

    item.update_by(stats)
    assert_equal 216 + 300 + 45,    item.total_personal.to_f # add income tax
    assert_equal 5000 - 561,        item.salary_in_fact
    assert_equal 200 + 100,         item.total_company

    assert_equal 5000 + 300,  item.total_sum
    assert_equal 200,         item.admin_amount
    assert_equal 5500,        item.total_sum_with_admin_amount
  end
end
