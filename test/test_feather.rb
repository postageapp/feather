require_relative './helper'

class TestFeather < Test::Unit::TestCase
  def test_module_loaded
    assert Feather

    assert Feather.version
    assert Feather.version.match(/^\d/)
    assert !Feather.version.match(/\n/)
  end

  def test_empty_template
    template = Feather.new('')

    assert template
    assert_equal '', template.render
  end
end
