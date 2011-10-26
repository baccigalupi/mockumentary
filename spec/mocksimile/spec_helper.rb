$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
require 'rspec'
require 'mockumentary'

FIXTURE_ROOT = File.dirname(__FILE__) + "/../fixtures"

# Requires supporting files with custom matchers and macros, etc,
Dir["#{File.dirname(__FILE__)}/../support/**/*.rb"].each {|f| require f}


RSpec.configure do |config|
  
end

