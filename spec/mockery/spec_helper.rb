$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
require 'rspec'
require 'mockumentary'

Bundler.require(:test)

# do the activerecord and schema load dance.
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3', 
  :database => SQLite3::Database.new("spec/mockery/test.db")
)
load('fixtures/db/schema.rb')
unless defined?(Rails)
  class Rails; end
end
FIXTURE_ROOT = File.dirname(__FILE__) + "/fixtures"

# Requires supporting files with custom matchers and macros, etc,
Dir["#{File.dirname(__FILE__)}/../support/**/*.rb"].each {|f| require f}

# Require fake AR files
Dir["#{File.dirname(__FILE__)}/fixtures/app/**/*.rb"].each {|f| require f}

def debuggery statement
  if $debug
    puts statement
  end
end

RSpec.configure do |config|
  
end
