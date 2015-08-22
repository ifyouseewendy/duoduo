require 'test_helper'

class SubCompanyTest < ActiveSupport::TestCase
  def setup
    @one = sub_companies(:one)
  end

  def test_add_file
    assert_empty @one.contracts

    @one.add_file(Rails.root.join('Gemfile'))
    assert 1, @one.contracts.count

    @one.add_file(Rails.root.join('Rakefile'))
    assert 2, @one.contracts.count

    @one.add_file(Rails.root.join('config.ru'), override: true)
    assert 1, @one.contracts.count
    assert 'config.ru', @one.contracts.first.file.identifier
  end
end
