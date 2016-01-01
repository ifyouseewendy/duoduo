require 'test_helper'

class EngineeringCorpTest < ActiveSupport::TestCase
  setup do
    @one = engineering_corps(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end
end
