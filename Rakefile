require 'rubygems'

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "feather"
  gem.homepage = "http://github.com/twg/feather"
  gem.license = "MIT"
  gem.summary = %Q{Light-weight text tempating system}
  gem.description = %Q{A simple light-weight text templating system}
  gem.email = "github@tadman.ca"
  gem.authors = [ "Scott Tadman" ]
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task default: :test
