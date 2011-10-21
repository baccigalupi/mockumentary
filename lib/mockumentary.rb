module Mockumentary
  def self.generate(klass)
    begin "Mockumentary::#{klass}".constantize
    rescue  
      class_eval <<-RUBY
        class #{klass} < Mockumentary::Model
          CLASS = ::#{klass}
        end
      RUBY
    end

    mockery = "Mockumentary::#{klass}".constantize
    mockery.mockify
  end
end

require 'collection'
require 'model'
