Bundler.require

module Mockumentary
  def self.generate(klass)
    begin mock_class = constantize klass
    rescue  
      build klass
    end

    mock_class = constantize klass
    mock_class.mockify
  end

  def self.build(klass)
    class_eval <<-RUBY
      class #{klass} < Mockumentary::Mockery
        CLASS = ::#{klass}
      end
    RUBY
  end

  def self.constantize(klass)
    "Mockumentary::#{klass}".constantize
  end

  def self.introspect dir = "#{Rails.root}/app/models", namespace = ''
     Dir.chdir(dir) do 
      Dir['*.rb'].each do |file|
        require "#{dir}/#{file}"
        ar_class = (namespace + file.gsub(/\.rb$/, '').classify).constantize
        generate(ar_class)
      end

      Dir['*'].each do |file|
        path = "#{dir}/#{file}"
        if File.directory?(path)
          namespace << "::" unless namespace.empty?
          namespace << "#{file.classify}::"
          introspect(path, namespace)
        end
      end
    end 
  end
end

require 'collection'
require 'mockery'
require 'mocksimile'
