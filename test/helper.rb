require 'rubygems'
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'feather'

class Minitest::Test
  def assert_exception(exception_class, message = nil)
    begin
      yield
    rescue exception_class
      # Expected
    else
      flunk(message || "Did not raise #{exception_class}")
    end
  end
end
