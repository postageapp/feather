require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
  
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

gem 'minitest'
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'feather'

class MiniTest::Test
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
