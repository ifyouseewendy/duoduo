require 'test_helper'

class SealItemTest < ActiveSupport::TestCase
  test "query_user" do
    assert_equal 'first table', SealItem.query_user(name: 'wendi')
    assert_equal 'first table', SealItem.query_user(name: 'larry')
    assert_equal 'second table', SealItem.query_user(name: 'dapian')
  end
end
