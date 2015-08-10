require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true

  test "role" do
    assert @alpha.in_administration?

    @alpha.in_business!
    assert @alpha.in_business?

    refute @alpha.in_finance?
  end
end
