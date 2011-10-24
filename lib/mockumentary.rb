Bundler.require

module Mockumentary
  def self.generate(klass)
    begin mock_class = constantize klass
    rescue  
      class_eval <<-RUBY
        class #{klass} < Mockumentary::Mockery
          CLASS = ::#{klass}
        end
      RUBY
    end

    mock_class = constantize klass
    mock_class.mockify
  end

  def self.constantize(klass)
    "Mockumentary::#{klass}".constantize
  end
end

require 'collection'
require 'mockery'
require 'mocksimile'
