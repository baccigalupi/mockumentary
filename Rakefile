# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "mockumentary"
  gem.homepage = "http://github.com/baccigalupi/mockumentary"
  gem.license = "MIT"
  gem.summary = %Q{An ActiveRecord mocking framework, for making your copius BDD rails tests not quite so slow}
  gem.description = <<-TEXT 
    With the happy proliferation of TDD, test suites are getting massive, and developer efficiency is dwindling
    as we wait for our tests to pass. There is a big tradeoff between making unit test more integrationish (and therefore more reliable) vs.
    making them very mocky, unity and fast. Mockumentary is a library for the later. It inspects the ActiveRecord universe and
    makes a series of AR mockeries that approximate model without hitting the database, or making any assertions. The assertions,
    they are still part of the developers job.
    
    Mocumentary has two types of AR mockeries: One is used within the Rails universe. It uses introspection to derive association
    and field information. The second is a static copy built from the first. This static version can be used outside the Rails
    test universe in a suite faster than the speed of Rails environment load time.
    
    Mocking isn't for everyone, so test-drive responsibly.
  TEXT
  gem.email = "baccigalupi@gmail.com"
  gem.authors = ["Kane Baccigalupi"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
