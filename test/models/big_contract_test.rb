require 'test_helper'

class BigContractTest < ActiveSupport::TestCase
  setup do
    @one = big_contracts(:one)
  end

  def test_ref_with_sub_company
    assert_equal sub_companies(:one).id, @one.sub_company.id
  end

  def test_ref_with_corporation
    assert_equal engineering_corps(:one).id, @one.corporation.id
  end
end
