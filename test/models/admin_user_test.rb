require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  def test_admin
    assert admin_users(:super_admin).admin?
    refute admin_users(:finance_admin).admin?
    refute admin_users(:business_admin).admin?

    # refute admin_users(:finance_senior).admin?
    # refute admin_users(:finance_junior).admin?
  end

  def test_finance_admin
    assert admin_users(:super_admin).finance_admin?
    assert admin_users(:finance_admin).finance_admin?
    # refute admin_users(:finance_senior).finance_admin?
  end

  def test_finance_normal
    # refute admin_users(:finance_admin).finance_normal?
    # assert admin_users(:finance_senior).finance_normal?
    # assert admin_users(:finance_junior).finance_normal?
  end
end
